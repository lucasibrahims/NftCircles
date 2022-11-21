// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract Circles is ERC721Enumerable, Ownable {
  using Strings for uint256;
  
   struct Word { 
      string name;
      string description;
      string bgHue;
      string circlesHue;
      uint256 r;
      uint256 x;
      uint256 y;
   }
  
  mapping (uint256 => Word) public words;
  
  constructor() ERC721("Random Circles", "CIR") {}

  // public
  function mint() public payable {
    uint256 supply = totalSupply();
    require(supply + 1 <= 1000);
    
    Word memory newWord = Word(
        string(abi.encodePacked('CIR #', uint256(supply + 1).toString())), 
        "Random colors. Random circles. Just colors and circles.",
        randomNum(361, block.difficulty, supply).toString(),
        randomNum(361, block.timestamp, supply).toString(),
        randomNum(350, block.timestamp, supply),
        randomNum(350, block.difficulty, supply),
        randomNum(340, block.difficulty, supply)
    );
    
    if (msg.sender != owner()) {
      require(msg.value >= 0.005 ether);
    }
    
    words[supply + 1] = newWord;
    _safeMint(msg.sender, supply + 1);
  }

  function randomNum(uint256 _mod, uint256 _seed, uint _salt) public view returns(uint256) {
      uint256 num = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }
  
  function buildImage(uint256 _tokenId) public view returns(string memory) {
      Word memory currentWord = words[_tokenId];
      return Base64.encode(bytes(
          abi.encodePacked(
              '<svg id="visual" viewBox="0 0 500 500" width="500" height="500" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">',
              '<rect x="0" y="0" width="500" height="500" fill="hsl(',currentWord.bgHue,', 50%, 25%)"></rect>',
              '<g fill="none" stroke="hsl(',currentWord.circlesHue,', 50%, 50%)" stroke-width="10"> ',
              '<circle r="',(currentWord.r%174).toString(),'" cx="',currentWord.x.toString(),'" cy="',currentWord.y.toString(),'"></circle><circle r="',(currentWord.r%127).toString(),'" cx="',((currentWord.x * 2)+(currentWord.r%174)).toString(),'" cy="',((currentWord.y * 3 / 2)+(currentWord.r%174)).toString(),'"></circle>',
              '<circle r="',(currentWord.r%71).toString(),'" cx="',((currentWord.x + 100)+(currentWord.r%174)).toString(),'" cy="',((currentWord.y + 70)+(currentWord.r%174)).toString(),'">',
              '</circle></g></svg>'        
          )
      ));
  }

  
  function buildMetadata(uint256 _tokenId) public view returns(string memory) {
      Word memory currentWord = words[_tokenId];
      return string(abi.encodePacked(
              'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                          '{"name":"', 
                          currentWord.name,
                          '", "description":"', 
                          currentWord.description,
                          '", "image": "', 
                          'data:image/svg+xml;base64,', 
                          buildImage(_tokenId),
                          '"}')))));
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
      require(_exists(_tokenId),"ERC721Metadata: URI query for nonexistent token");
      return buildMetadata(_tokenId);
  }

  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);
  }
}