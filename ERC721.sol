pragma solidity ^0.4.23;

import "./PetBase.sol";

// ERC721 interface
contract ERC721 {
    
    bytes4 constant INTERFACE_SIGNATURE_ERC721 =
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("ownerOf(uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("takeOwnership(uint256)")) ^
        bytes4(keccak256("transfer(address,uint256)"));
    
    function implementsERC721() public pure returns (bool);
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) external payable;
    function transfer(address _to, uint256 _tokenId) public payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    
    // function name() public pure returns (string _name);
    // function symbol() public pure returns (string _symbol);
    
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);

    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
}