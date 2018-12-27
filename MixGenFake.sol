
pragma solidity ^0.4.23;

/**
 * Warning! 
 * This is a fake version of gene generator contract. This contract is necessary just to run smart contract of the game for our developers and for you!
 * The real version of the generator is strictly secret and will not be published.
 */

contract MixGenFake{
    
    // 
    address parent;
    
    constructor(address _nftAddr) public {
        parent = _nftAddr;
    }
 
    function isMixGen() public pure returns (bool) {
        return true;
    }
 
    function mixGenes(uint64 userNumber, uint256 genes1, uint256 genes2) public pure returns (uint256 genes, uint16 quality) {
        genes = (genes1 > genes2) ? genes1+userNumber : genes2+userNumber;
        quality = 55375;
    }
    
    
    function magicCube(uint64 userNumber, uint16 petQuality) public pure returns (uint256 genes, uint16 quality) {
        genes = 42120379430592025765448033768736856703739151940001904851365893011+userNumber;
        quality = petQuality;
    }
 
    function openEgg(uint64 userNumber, uint16 eggQuality) public pure returns (uint256 genes, uint16 quality) {
	  genes = 42120379430592025765448033768736856703739151940001904851365893011+userNumber;
      quality = eggQuality;
    }
	
	function uniquePet(uint64 newPetId) public pure returns (uint256 genes, uint16 quality) {
        genes = 42120379430592025765448033768736856703739151940001904851365893011+newPetId;
		quality = 32223;
    }
}