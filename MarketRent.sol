pragma solidity ^0.4.23;

import "./MarketBase.sol";

contract MarketRent is MarketPublic, MarketSystem {

    bool public isSiringMarket = true;

    constructor(address _nftAddr) public
        MarketBase(_nftAddr) {}

    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    ) external nftRequest whenNotPaused {
        
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));
        
        require(_startingPrice > 0 || _endingPrice > 0 );


        _escrow(_seller, _tokenId);
        
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId) external payable nftRequest whenNotPaused {
        address seller = tokenIdToAuction[_tokenId].seller;
        _bid(_tokenId, msg.value);
        
        _transfer(seller, _tokenId);
    }
}

