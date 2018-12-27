pragma solidity ^0.4.23;

import "./ERC721.sol";
import "./AccessControl.sol";


contract MarketBase is Pausable {
    
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x19595b11);

    ERC721 public parent;
    
    uint public minDuration;
    uint public maxDuration;

    struct Auction {
        address seller;
        uint256 startPrice;
        uint256 endPrice;
        uint64 duration;
        uint64 startedAt;
    }
    
    mapping (uint256 => Auction) tokenIdToAuction;
    
    constructor(address _nftAddress) public {
        minDuration = 1 minutes;
        maxDuration = 30 days;

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        parent = candidateContract;
    }

    event AuctionCreated(uint256 tokenId, uint256 startPrice, uint256 endPrice, uint64 duration, uint64 startedAt);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);
    
    modifier nftRequest() {
        
        if(address(parent)!=address(0))
            require(msg.sender == address(parent));
            
        _;
    }
    
    function setParentAddress(address _address) public onlyOwner
    {
        ERC721 candidateContract = ERC721(_address);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        parent = candidateContract;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return parent.ownerOf(_tokenId) == _claimant;
    }

    function _isActiveAuction(Auction storage _auction) internal view returns (bool) {
        return _auction.startedAt > 0;
    }

    function _escrow(address _owner, uint256 _tokenId) internal {
        parent.transferFrom(_owner, this, _tokenId);
    }

    function _transfer(address _purchasor, uint256 _tokenId) internal {
 
        parent.transfer(_purchasor, _tokenId);
    }

    // Creating new auction
    function _addAuction(uint256 _tokenId, Auction _auction) internal {

        require(_auction.duration >= minDuration && _auction.duration <= maxDuration);

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(uint256(_tokenId),
            uint256(_auction.startPrice),
            uint256(_auction.endPrice),
            uint64(_auction.duration),
            uint64(_auction.startedAt)
        );
    }

    function setMinDuration(uint _duration) external onlyOwner {
        minDuration = _duration;
    }

    function setMaxDuration(uint _duration) external onlyOwner {
        maxDuration = _duration;
    }

    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }


    function _bid(uint256 _tokenId, uint256 _bidAmount) internal returns (uint256) {

        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isActiveAuction(auction));

        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        address seller = auction.seller;

        _removeAuction(_tokenId);

        seller.transfer(price);

        uint256 bidExcess = _bidAmount - price;

        if(bidExcess>0)
            msg.sender.transfer(bidExcess);
        
        emit AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    function _currentPrice(Auction storage _auction) internal view returns (uint256) {
        uint256 secsElapsed = now - _auction.startedAt;
        return _computeCurrentPrice(
            _auction.startPrice,
            _auction.endPrice,
            _auction.duration,
            secsElapsed
        );
    }

    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    function _computeCurrentPrice( uint256 _startPrice, uint256 _endPrice, uint256 _duration, uint256 _secondsPassed ) internal pure returns (uint256 _price) {
        _price = _startPrice;
        if (_secondsPassed >= _duration) {
            _price = _endPrice;
        }
        else if (_duration > 0) {
            int256 priceDifference = int256(_endPrice) - int256(_startPrice);
            int256 currentPriceDifference = priceDifference * int256(_secondsPassed) / int256(_duration);
            int256 currentPrice = int256(_startPrice) + currentPriceDifference;

            _price = uint256(currentPrice);
        }
        return _price;
    }
}

contract MarketPublic is MarketBase {
    
    function getCurrentPrice(uint256 _tokenId) public view returns (uint256) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isActiveAuction(auction));
        return _currentPrice(auction);
    }
    
    function getAuction(uint256 _tokenId) public view returns ( address seller, uint256 startPrice, uint256 endPrice, uint256 duration, uint256 startedAt ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isActiveAuction(auction));
        return ( auction.seller, auction.startPrice, auction.endPrice, auction.duration, auction.startedAt);
    }
    
    function cancelAuction(uint256 _tokenId)
        whenNotPaused external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isActiveAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }
}

contract MarketSystem is MarketBase {
    
    function withdrawBalance() external {
        
        address parentAddress = address(parent);
        
        require(msg.sender == owner || msg.sender == parentAddress);

        parentAddress.transfer(address(this).balance);
    }
    
    function addFunds() external payable {}
    
    function cancelAuctionWhenPaused(uint256 _tokenId) whenPaused onlyOwner external {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isActiveAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

}