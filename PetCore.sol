pragma solidity ^0.4.23;

import "./Market.sol";
import "./EggPurchase.sol";

// Launch it
contract PetCore is MarketPlace, EggPurchase{
    
    event ContractUpgrade(address newContract);
    
    address public newContractAddress;
    
    constructor() public {
        paused = true;
    }
    
    function setNewAddress(address _v2Address) external onlyOwner whenPaused {
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }
        
    function getPet(uint256 _tokenId) public view returns (
        uint64 birthTime,
        uint256 genes,
        uint64 breedTimeout,
        uint16 quality,
        address owner,
        uint64[4] parents
    ) {
        uint64 tokenId64bit = uint64(_tokenId);
        
        Pet storage pet = pets[tokenId64bit];
        
        birthTime = pet.birthTime;
        genes = pet.genes;
        breedTimeout = uint64(breedTimeouts[tokenId64bit]);
        quality = pet.quality;
        
        owner = petIndexToOwner[tokenId64bit];
        
        parents = familyTree[tokenId64bit];
    }
    
    function unpause() public onlyOwner whenPaused {
        require(saleMarket != address(0));
        require(rentMarket != address(0));
        require(geneScience != address(0));
        require(newContractAddress == address(0));

        super.unpause();
    }
    
    function withdrawBalance() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}
