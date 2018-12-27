pragma solidity ^0.4.23;

import "./PetBase.sol";
import "./ERC721.sol";


// Ownership
contract PetOwnership is PetBase, ERC721 {

    string public constant name = "TRON Birds";
    string public constant symbol = "TB";
    
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return (_interfaceID == INTERFACE_SIGNATURE_ERC721);
    }
    
    function implementsERC721() public pure returns (bool) {
        return true;
    }

    function _owns(address _claimant, uint64 _tokenId) internal view returns (bool) {

        return petIndexToOwner[_tokenId] == _claimant;
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        uint64 _tokenId64bit = uint64(_tokenId);
        return petIndexToApproved[_tokenId64bit] == _claimant;
    }

    function _approve(uint256 _tokenId, address _approved) internal {
        uint64 _tokenId64bit = uint64(_tokenId);
        petIndexToApproved[_tokenId64bit] = _approved;
    }

    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    function transfer(
        address _to,
        uint256 _tokenId
    )
        public payable
        whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_owns(msg.sender, uint64(_tokenId)));

        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(
        address _to,
        uint256 _tokenId
    ) 
        external payable
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, uint64(_tokenId)));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any kitties (except very briefly
        // After a gen0 cat is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, uint64(_tokenId)));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }


    function totalSupply() public view returns (uint) {
        return tokensCount;
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        uint64 _tokenId64bit = uint64(_tokenId);
        owner = petIndexToOwner[_tokenId64bit];
        
        require(owner != address(0));
    }
}