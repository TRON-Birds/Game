pragma solidity ^0.4.23;

import "./AccessControl.sol";
import "./ERC721.sol";
import "./MarketRent.sol";
import "./MarketSale.sol";

// Gen mixer
contract MixGenInterface {
    function isMixGen() public pure returns (bool);
    function mixGenes(uint64 userNumber, uint256 genes1, uint256 genes2) public returns (uint256 genes, uint16 quality);
    function magicCube(uint64 userNumber, uint16 petQuality) public returns (uint256 genes, uint16 quality);
    function openEgg(uint64 userNumber, uint16 eggQuality) public returns (uint256 genes, uint16 quality);
}

// Configuration of external contracts
contract ExternalContracts is Ownable {
    
    MixGenInterface public geneScience;
    MarketSale public saleMarket;
    MarketRent public rentMarket;
    
    // Setting external contracts addresses
    
    function setMixGenAddress(address _address) external onlyOwner {
        MixGenInterface candidateContract = MixGenInterface(_address);
        require(candidateContract.isMixGen());
        
        geneScience = candidateContract;
    }
    
    function setMarketRentAddress(address _address) external onlyOwner {
        MarketRent candidateContract = MarketRent(_address);
        require(candidateContract.isSiringMarket());

        rentMarket = candidateContract;
    }

    function setMarketSellAddress(address _address) external onlyOwner {
        MarketSale candidateContract = MarketSale(_address);
        require(candidateContract.isSaleMarket());

        saleMarket = candidateContract;
    }
}