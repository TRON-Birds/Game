pragma solidity ^0.4.23;

import "./AccessControl.sol";

// Population settings and base functions
contract PopulationControl is Pausable {
    
    // Starter breed timeout is 12 hours
    uint32 public breedTimeout = 12 hours;
    uint32 maxTimeout = 178 days;
    
    // Breed price in percents of recommended child price
    uint8 public breedPricePercent = 95;
    uint8 minBreedPricePercent = 92;
    uint8 maxBreedPricePercent = 103;
    
    function setBreedTimeout(uint32 _timeout) external onlyOwner {
        require(_timeout <= maxTimeout);
        
        breedTimeout = _timeout;
    }
    
    function setBreedPricePercent(uint8 _pricePercent) external onlyOwner {
        
        require(_pricePercent >= minBreedPricePercent && _pricePercent <= maxBreedPricePercent);
        
        breedPricePercent = _pricePercent;
    }
}