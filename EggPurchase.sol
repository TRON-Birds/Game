pragma solidity ^0.4.23;

import "./ExternalContracts.sol";
import "./PetOwnership.sol";


// Settings for eggs created by administration
contract EggMinting is PetOwnership{

    mapping (uint16 => uint16) public eggLimits;
    mapping (uint16 => uint16) public purchesedEggs;
    
    // Setting default eggs
    constructor() public {
        eggLimits[55375] = 200;
    }

    // Changing eggs limit by owner
    function setEggLimit(uint16 _quality, uint16 _limit) external onlyOwner {
        eggLimits[_quality] = _limit;
    }
    
    // Checking egg availablity
    function eggAvailable(uint16 _quality) view public returns(bool) {
        return (eggLimits[_quality] > purchesedEggs[_quality]);
    }
}

// Buying eggs from the company
contract EggPurchase is EggMinting, ExternalContracts {
    
    // Purchasing egg
    function purchaseEgg(uint64 _userNumber, uint16 _quality) external payable whenNotPaused returns(uint64 _petId) {
        
        // Checking egg availablity
        require(eggAvailable(_quality));

        // Calculating price, for unique pet - no discount
        uint256 eggPrice = recommendedPrice(_quality);

        // Checking payment amount
        require(msg.value >= eggPrice);
        
        // Increment egg counter
        purchesedEggs[_quality]++;
        
        // Initialize variables for store child genes and quility
        uint256 childGenes;
        uint16 childQuality;

        // Get genes and quality of new pet by opening egg through external interface
        (childGenes, childQuality) = geneScience.openEgg(_userNumber, _quality);
         
        // Creating new pet
        return createPet(
            childGenes,      // Genes string
            childQuality,    // Child quality by open egg
            msg.sender       // Owner
        );
    }
}