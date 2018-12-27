pragma solidity ^0.4.23;

import "./PopulationControl.sol";

// Pet base contract
contract PetBase is PopulationControl {
    
    
    event Birth(address owner, uint64 petId, uint16 quality, uint256 genes);
    event Death(uint64 petId);
    event Transfer(address from, address to, uint256 tokenId);
    
    
    struct Pet {
        uint256 genes;
        uint64 birthTime;
        uint16 quality;
    }
    
    
    mapping (uint64 => Pet) public pets;
    mapping (uint64 => address) public petIndexToOwner;
    mapping (uint64 => address) public petIndexToApproved;
    mapping (address => uint256) ownershipTokenCount;
    mapping (uint64 => uint64) breedTimeouts;
    
    mapping (uint64 => uint64[4]) familyTree;
    
 
    uint64 tokensCount;
    uint64 public lastTokenId;

    // pet saving
    function createPet(
        uint256 _genes,
        uint16 _quality,
        address _owner
    )
        internal
        returns (uint64)
    {
        Pet memory _pet = Pet({
            genes: _genes,
            birthTime: uint64(now),
            quality: _quality
        });
        
        lastTokenId++;
        tokensCount++;
        
        uint64 newPetId = lastTokenId;
                
        pets[newPetId] = _pet;
        
        _transfer(0, _owner, newPetId);
        
        breedTimeouts[newPetId] = uint64( now + (breedTimeout / 2) );
        emit Birth(_owner, newPetId, _quality, _genes);

        return newPetId;
    }
    
    function removeToken(uint64 _tokenId) internal {
        address owner = petIndexToOwner[_tokenId];
        
        ownershipTokenCount[owner]--;
        
        delete(breedTimeouts[_tokenId]);
        delete(petIndexToApproved[_tokenId]);
        delete(petIndexToOwner[_tokenId]);
        delete(pets[_tokenId]);
        
        tokensCount--;
        
        emit Death(_tokenId);
    }

    // Transfer pet function
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        uint64 _tokenId64bit = uint64(_tokenId);
        
        ownershipTokenCount[_to]++;
        petIndexToOwner[_tokenId64bit] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete petIndexToApproved[_tokenId64bit];
        }
        
         emit Transfer(_from, _to, _tokenId);
    }
    
    function setParents(uint64 _tokenId, uint64 _parent1, uint64 _parent2, uint64 _parent3, uint64 _parent4) internal {
        
        familyTree[_tokenId][0] = _parent1;
        familyTree[_tokenId][1] = _parent2;
        familyTree[_tokenId][2] = _parent3;
        familyTree[_tokenId][3] = _parent4;
        
    }
    
    function recommendedPrice(uint16 quality) public pure returns(uint256 price) {
        price = 1000;
        
        // disabled for wrong parrot quality
        if(quality > uint16(0xF000) || quality < uint16(0x1000))
            return 0;
        
        uint256 revertQuality = uint16(0xF000) - quality;
        uint256 oneLevel = uint16(0x2000);
        uint256 oneQuart = oneLevel/4;
        
        uint256 fullLevels = revertQuality/oneLevel;
        uint256 fullQuarts =  (revertQuality % oneLevel) / oneQuart ;
        
        uint256 surplus = revertQuality - (fullLevels*oneLevel) - (fullQuarts*oneQuart);
        
        
        // coefficeint is 4.4 per level
        price = price * 44**fullLevels;
        price = price / 10**fullLevels;
        
        // quart coefficient is sqrt(sqrt(4.4))
        if(fullQuarts != 0)
        {
            price = price * 14483154**fullQuarts;
            price = price / 10**(7 * fullQuarts);
        }

        // for surplus we using next quart coefficient
        if(surplus != 0)
        {
            uint256 nextQuartPrice = (price * 14483154) / 10**7;
            uint256 surPlusCoefficient = surplus * 10**6  /oneQuart;
            uint256 surPlusPrice = ((nextQuartPrice - price) * surPlusCoefficient) / 10**6;
            
            price+= surPlusPrice;
        }
		
		price*=100000;
    }
    
    function getGradeByQuailty(uint16 quality) public pure returns (uint8 grade) {
        
        require(quality <= uint16(0xF000));
        require(quality >= uint16(0x1000));
        
        if(quality == uint16(0xF000))
            return 7;
        
        quality+= uint16(0x1000);
        
        return uint8 ( quality / uint16(0x2000) );
    }
}
