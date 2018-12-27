pragma solidity ^0.4.23;

import "./PetOwnership.sol";
import "./ExternalContracts.sol";

// Breeding
contract PetBreeding is PetOwnership, ExternalContracts {
    
    function isReadyToBreed(uint64 tokenId) public view returns (bool) {
        
        require( breedTimeouts[tokenId] <= now );

        return true;
    }
    
    function getSystemBreedPrice(Pet storage pet1, Pet storage pet2) internal view returns(uint256 price) {
         
        uint32 averageQuality = (uint32(pet1.quality) + pet2.quality) / 2;
         
        price = recommendedPrice( uint16 (averageQuality) );
        
        price = ( price * breedPricePercent ) / 100;
    }
    
    function _isValidMatingPair(uint64 petId1, uint64 petId2) internal view returns (bool success) {
        
        uint64[4] memory parentsPet1 = familyTree[petId1];
        uint64[4] memory parentsPet2 = familyTree[petId1];
        
        // Can't mate with himself
        if(petId1 == petId2)
            return false;
        
        // If one of them was created by Magic Cube - return true
        if (parentsPet1[2] != 0)
            return true;
        
        if (parentsPet2[2] != 0)
            return true;
            
        // If one of them was created with purchasing egg - return true
        if (parentsPet1[0] == 0)
            return true;
        
        if (parentsPet2[0] == 0)
            return true;
        
        // Pets can not breed with parents
        if (petId1 == parentsPet1[0] || petId1 == parentsPet1[1] ) 
            return false;
        
        if (petId2 == parentsPet2[0] || petId2 == parentsPet2[1] ) 
            return false;
        
        // Pets can not have common parents
        if (parentsPet1[0] == parentsPet2[0] || parentsPet1[0] == parentsPet2[1] ) 
            return false;
            
        if (parentsPet1[1] == parentsPet2[0] || parentsPet1[1] == parentsPet2[1] ) 
            return false;
            
        return true;
    }
}
