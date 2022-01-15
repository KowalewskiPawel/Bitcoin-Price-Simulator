// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

import "./libraries/Base64.sol";

contract CryptoFighters is ERC721 {
  struct CharacterAttributes {
    string name;
    string imageURI;
    uint256 money;
    uint256 bitcoins;
  }

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
  mapping(address => uint256) public nftHolders;

  event CharacterNFTMinted(
    address sender,
    uint256 tokenId,
    uint256 characterIndex
  );
  event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);

  uint256 bitcoinPrice;

  constructor() ERC721("Crypto Fighters", "CFGH") {
    bitcoinPrice = 1;
    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
  {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory money = Strings.toString(charAttributes.money);
    string memory bitcoins = Strings.toString(charAttributes.bitcoins);
    string memory image = Strings.toString(charAttributes.imageURI);
    string memory description = Strings.toString(charAttributes.description);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            charAttributes.name,
            " - NFT #: ",
            Strings.toString(_tokenId),
            '", "description": "',
            description,
            '", "image": "ipfs://',
            image,
            '", "attributes": [ { "trait_type": "$Fiats", "value": ',
            money,
            '}, { "trait_type": "BTC", "value": ',
            bitcoins,
            "} ]}"
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    return output;
  }

  function checkIfUserHasNFT()
    public
    view
    returns (CharacterAttributes memory)
  {
    uint256 userNftTokenId = nftHolders[msg.sender];
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    } else {
      CharacterAttributes memory emptyStruct;
      return emptyStruct;
    }
  }

  function getBitcoinPrice() public view returns (bitcoinPrice) {
    return bitcoinPrice;
  }

  function mintCharacterNFT(
    string memory _name,
    string memory _description,
    string memory _imageURI
  ) external {
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = CharacterAttributes({
      name: _name,
      description: _description,
      imageURI: _imageURI,
      money: 1000,
      bitcoins: 0
    });

    nftHolders[msg.sender] = newItemId;

    _tokenIds.increment();

    emit CharacterNFTMinted(msg.sender, newItemId);
  }

  function attackBoss() public {
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[
      nftTokenIdOfPlayer
    ];
  }
}
