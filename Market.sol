pragma solidity ^0.4.23;

import "./PetBreeding.sol";

// Marketplace
contract MarketPlace is PetBreeding{

    // Selling pet request
    function sellPet(uint64 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint64 _duration) external whenNotPaused {
        
        // Checking owner
        require(_owns(msg.sender, _tokenId));
        
        // Approve token access to sale market
        _approve( uint256 (_tokenId) , saleMarket);

        // Creating auction        
        saleMarket.createAuction(_tokenId, _startingPrice, _endingPrice, _duration, msg.sender);
    }
    
    function rentPet(uint64 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint64 _duration) external whenNotPaused {
        
        // Checking owner
        require(_owns(msg.sender, _tokenId));
        
        // Checking pet for breed avaliablity
        require(isReadyToBreed(_tokenId));

        // Approve token acces to rent market
        _approve( uint256 (_tokenId) , rentMarket);
    
        // Creating auction  
        rentMarket.createAuction(_tokenId, _startingPrice, _endingPrice, _duration, msg.sender);
    }

    // Make bid on siring auction
    function bidOnSiringAuction(uint64 _userNumber, uint64 _sireId, uint64 _matronId) external payable {
   
        // Require owns one of breeding pets
        require(_owns(msg.sender, _matronId) || _owns(msg.sender, _sireId));

        // calculating, which pet owns sender
        uint64 secondPet = _matronId;
        uint64 userPet = _sireId;
        
        if(_owns(msg.sender, _matronId))
        {
            secondPet = _sireId;
            userPet = _matronId;
        }
        
        // Checking pets for breed avaliablity
        require(isReadyToBreed(userPet));
        require(_isValidMatingPair(_sireId, _matronId));
        
        // Cetting information about pets
        Pet storage pet1 = pets[_sireId];
        Pet storage pet2 = pets[_matronId];
        
        // Calculating and checking prices
        uint256 systemPrice = getSystemBreedPrice(pet1, pet2);
        uint256 auctionPrice = rentMarket.getCurrentPrice(secondPet);
        uint256 totalBreedPrice = systemPrice + auctionPrice;
        
        require(msg.value >= totalBreedPrice);
        
        // Bid on auction
        rentMarket.bid.value(auctionPrice)(secondPet);
        
        // Calculating excess
        uint256 bidExcess = msg.value - totalBreedPrice;
        
        if(bidExcess > 0)
            msg.sender.transfer(bidExcess);

        // Creating a new pet
        uint256 childGenes;
        uint16 childQuality;
       
        // Request for calculating genes and quality to gene scinece
        (childGenes, childQuality) = geneScience.mixGenes(_userNumber, pet1.genes, pet2.genes);
        
        // Increase breeding timeouts for parents
        breedTimeouts[_sireId] = uint64( now + breedTimeout );
        breedTimeouts[_matronId] = uint64( now + breedTimeout );

        // Saving new pet
        uint64 newPetId = createPet(
            childGenes,
            childQuality,
            msg.sender
        );
        
        // Saving family tree
        setParents(newPetId, _sireId, _matronId, 0, 0);
    }
    
    function sireOwnPets(uint64 _userNumber, uint64 _sireId, uint64 _matronId) external payable {
        
        // require to own two pets
        require(_owns(msg.sender, _matronId) && _owns(msg.sender, _sireId));
        
        // checking pets for breed avaliablity
        require(isReadyToBreed(_sireId) && isReadyToBreed(_matronId));
        require(_isValidMatingPair(_sireId,_matronId));
        
        // getting pets information
        Pet storage pet1 = pets[_sireId];
        Pet storage pet2 = pets[_matronId];

        // calculating and checking prices
        uint256 breedPrice = getSystemBreedPrice(pet1, pet2);
        require(msg.value >= breedPrice);
        
        // excess
        uint256 bidExcess = msg.value - breedPrice;
        
        if(bidExcess > 0)
            msg.sender.transfer(bidExcess);

        // creating new pet
        uint256 childGenes;
        uint16 childQuality;
        
        // request for calculating genes and quality to gene scinece
        (childGenes, childQuality) = geneScience.mixGenes(_userNumber, pet1.genes, pet2.genes);
        
        // increase breed timeouts for parents
        breedTimeouts[_sireId] = uint64( now + breedTimeout );
        breedTimeouts[_matronId] = uint64( now + breedTimeout );

        // saving new pet
        uint64 newPetId = createPet(
            childGenes,
            childQuality,
            msg.sender
        );
        
        // saving family tree
        setParents(newPetId, _sireId, _matronId, 0, 0);
    }
    
    function useMagicCube(uint64 _userNumber, uint64 _tokenId1, uint64 _tokenId2, uint64 _tokenId3, uint64 _tokenId4) external {
        
        // require to own all pets
        require(_owns(msg.sender, _tokenId1) && _owns(msg.sender, _tokenId2) && _owns(msg.sender, _tokenId3) && _owns(msg.sender, _tokenId4));
        require(_tokenId1 != _tokenId2 && _tokenId1 != _tokenId3 && _tokenId1 != _tokenId4);
        require(_tokenId2 != _tokenId3 && _tokenId2 != _tokenId4);
        require(_tokenId3 != _tokenId4);
        
         // getting pets information
        Pet storage pet1 = pets[_tokenId1];
        Pet storage pet2 = pets[_tokenId2];
        Pet storage pet3 = pets[_tokenId3];
        Pet storage pet4 = pets[_tokenId4];

        // all pets must have same grade. also magic cube not available for higher grade 1
        uint8 petsGrade = getGradeByQuailty(pet1.quality);
        
        require(petsGrade != 1);
        
        require(    getGradeByQuailty(pet2.quality) == petsGrade &&
                    getGradeByQuailty(pet3.quality) == petsGrade &&
                    getGradeByQuailty(pet4.quality) == petsGrade
                );
        
        // calculating quality of new pet
        uint16 cubeQuality = getCubeQuality(pet1.quality, pet2.quality, pet3.quality, pet4.quality);
        
        // remove tokens
        removeToken(_tokenId1);
        removeToken(_tokenId2);
        removeToken(_tokenId3);
        removeToken(_tokenId4);
        
        // creating new pet
        uint256 childGenes;
        uint16 childQuality;
        
        // request for calculating genes and quality to gene scinece
        (childGenes, childQuality) = geneScience.magicCube(_userNumber, cubeQuality);
        
        // creating new pet
        uint64 newPetId = createPet(
            childGenes, 
            childQuality, 
            msg.sender
        );
        
        // saving family tree
        setParents(newPetId, _tokenId1, _tokenId2, _tokenId3, _tokenId4);
    }
    
    function getCubeQuality(uint16 _quality1, uint16 _quality2, uint16 _quality3, uint16 _quality4) internal pure returns (uint16 cube_quality) {
        
        // calculating average quality
        uint32 summQuailty = uint32(_quality1) + _quality2 + _quality3 + _quality4;
        uint16 average_quality = uint16(summQuailty/4);
        
        // applying a bonus for using a cube
        uint16 bonus_quality = uint16(0x2000);
        cube_quality = average_quality - bonus_quality;
    }
    
    function withdrawMarketBalances() external onlyOwner {
        saleMarket.withdrawBalance();
        rentMarket.withdrawBalance();
    }

}
