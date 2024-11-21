const hre = require("hardhat");

async function main() {
    // Déployer le contrat ERC721 (MyERC721Token)
    const MyToken721 = await hre.ethers.getContractFactory("MyERC721Token");
    const myToken721 = await MyToken721.deploy();
    await myToken721.deployed();
    console.log(`MyERC721Token deployed at: ${myToken721.address}`);

    // Adresse du contrat Evaluator (déjà déployé)
    const evaluatorAddress = "0x7759a66191f6e80ff8A2C0ab833886C7b632bbB7";

    // ** Étape 1: Enregistrer comme breeder **
    try {
        console.log("Registering as a breeder...");
        const registerTx = await myToken721.registerMeAsBreeder({ value: hre.ethers.utils.parseEther("0.000000001") });
        await registerTx.wait();
        console.log(`Address ${evaluatorAddress} registered as breeder`);
    } catch (error) {
        console.error("Error during registration:", error);
        return;
    }

    // ** Étape 2: Déclarer un animal **
    const name = "jSkpn877eN2Jm90";
    const wings = false;
    const legs = 3;
    const sex = 0;

    let animalId;
    try {
        console.log("Declaring an animal...");
        const mintTx = await myToken721.declareAnimal(sex, legs, wings, name);
        const receipt = await mintTx.wait();
        animalId = receipt.events[0].args.tokenId.toString();
        console.log(`Animal declared with ID: ${animalId}`);
    } catch (error) {
        console.error("Error during animal declaration:", error);
        return;
    }

    // ** Étape 3: Mettre l'animal en vente **
    try {
        console.log("Offering the animal for sale...");
        const offerTx = await myToken721.offerForSale(animalId, hre.ethers.utils.parseEther("0.0001"));
        await offerTx.wait();
        console.log(`Animal with ID ${animalId} is now for sale for 0.0001 ether`);
    } catch (error) {
        console.error("Error during offering the animal for sale:", error);
        return;
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
