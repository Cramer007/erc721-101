// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./IExerciceSolution.sol";

contract MyERC721Token is ERC721, IExerciceSolution, ERC721Burnable {
    uint256 public nextTokenId;
    mapping(uint256 => Animal) public mapanimal;
    mapping(address => bool) public breeders; // Mapping des éleveurs
    mapping(uint256 => Sale) public sales;    // Mapping pour suivre les animaux en vente

    struct Animal {
        string name;
        bool wings;
        uint legs;
        uint sex;
        bool isDead;
    }

    struct Sale {
        bool isForSale;
        uint256 price;
    }

    constructor() ERC721("MyERC721Token", "MTK") {
        nextTokenId = 1; // Commencer à 1 pour éviter des problèmes avec les IDs 0
    }

    // Fonction pour enregistrer un éleveur
    function registerMeAsBreeder() external payable override {
        require(msg.value >= registrationPrice(), "Registration fee required");
        breeders[msg.sender] = true;
    }

    // Vérifie si une adresse est un éleveur
    function isBreeder(address account) external view override returns (bool) {
        return breeders[account];
    }

    // Prix d'enregistrement (par défaut ici à 0.01 ether)
    function registrationPrice() public pure override returns (uint256) {
        return 0.000000001 ether;
    }

    // Fonction pour déclarer un nouvel animal avec des caractéristiques spécifiques
    function declareAnimal(uint sex, uint legs, bool wings, string calldata name) external override returns (uint256) {
        require(breeders[msg.sender], "Only breeders can declare animals");

        uint256 tokenId = nextTokenId;
        mapanimal[tokenId] = Animal(name, wings, legs, sex, false);
        _mint(msg.sender, tokenId);
        nextTokenId++;

        return tokenId;
    }

    // Fonction pour déclarer un animal comme mort
    function declareDeadAnimal(uint animalNumber) external override {
        require(breeders[msg.sender], "Only breeders can declare dead animals");
        require(ownerOf(animalNumber) == msg.sender, "Only owner can declare dead animal");
        require(!mapanimal[animalNumber].isDead, "Animal is already dead");

        mapanimal[animalNumber].isDead = true; // Marquer l'animal comme mort
    }

    // Fonction pour offrir un animal en vente
    function offerForSale(uint animalNumber, uint price) external override {
        require(ownerOf(animalNumber) == msg.sender, "Only the owner can offer the animal for sale");
        require(!mapanimal[animalNumber].isDead, "Cannot sell a dead animal");

        sales[animalNumber] = Sale(true, price);
    }

    // Fonction pour vérifier si un animal est en vente
    function isAnimalForSale(uint animalNumber) external view override returns (bool) {
        return sales[animalNumber].isForSale;
    }

    // Fonction pour obtenir le prix de vente d'un animal
    function animalPrice(uint animalNumber) external view override returns (uint256) {
        require(sales[animalNumber].isForSale, "Animal is not for sale");
        return sales[animalNumber].price;
    }

    // Fonction pour acheter un animal mis en vente
    function buyAnimal(uint animalNumber) external payable override {
        require(sales[animalNumber].isForSale, "Animal is not for sale");
        require(msg.value >= sales[animalNumber].price, "Not enough Ether to buy the animal");

        address seller = ownerOf(animalNumber);
        _transfer(seller, msg.sender, animalNumber);
        payable(seller).transfer(msg.value);

        // Mettre à jour l'état de la vente
        sales[animalNumber].isForSale = false;
    }

    // Récupère les caractéristiques d'un animal
    function getAnimalCharacteristics(uint animalNumber) external view override returns (string memory, bool, uint, uint) {
        Animal memory animal = mapanimal[animalNumber];
        return (animal.name, animal.wings, animal.legs, animal.sex);
    }

    // Récupère un token par index pour un propriétaire donné
    function tokenOfOwnerByIndex(address owner, uint256 index) external view override returns (uint256) {
        uint count = 0;
        for (uint256 i = 1; i < nextTokenId; i++) {
            if (ownerOf(i) == owner) {
                if (count == index) {
                    return i;
                }
                count++;
            }
        }
        revert("Owner does not own a token at this index");
    }

    // Fonctions par défaut pour satisfaire l'interface IExerciceSolution
    function declareAnimalWithParents(uint, uint, bool, string calldata, uint, uint) external pure override returns (uint256) {
        return 0;
    }

    function getParents(uint) external pure override returns (uint256, uint256) {
        return (0, 0);
    }

    function canReproduce(uint) external pure override returns (bool) {
        return false;
    }

    function reproductionPrice(uint) external pure override returns (uint256) {
        return 0;
    }

    function offerForReproduction(uint, uint) external pure override returns (uint256) {
        return 0;
    }

    function authorizedBreederToReproduce(uint) external pure override returns (address) {
        return address(0);
    }

    function payForReproduction(uint) external payable override {}
}
