import { ethers } from "ethers";

import abi from "./abi/NFTMinter.json";

type CollectionData = {
  name: string;
  symbol: string;
  supplyLimit: number;
};

export class Collection {
  private collectionData: CollectionData;
  private client: ethers.Provider;
  private contractAddress: string | null = null;
  private contract: ethers.Contract | null = null;

  constructor(collectionData: CollectionData) {
    this.collectionData = collectionData;

    const url =
      process.env.MODE === "dev"
        ? "https://data-seed-prebsc-1-s1.binance.org:8545/" // Testnet URL
        : "https://bsc-dataseed.binance.org/"; // Mainnet URL
    this.client = new ethers.JsonRpcProvider(url);
  }

  // Получить адрес контракта
  public get address(): string | null {
    return this.contractAddress;
  }

  // Деплой смарт-контракта
  async deploy(wallet: ethers.HDNodeWallet) {
    if (!wallet) {
      throw new Error("Wallet is required for deployment");
    }

    // Убедитесь, что у вас есть байткод контракта
    const bytecode = "0x..."; // Замените на ваш байткод контракта
    const abi = [
      /* Вставьте ваш ABI */
    ];

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const deployedContract = await factory.deploy(
      this.collectionData.name,
      this.collectionData.symbol,
      this.collectionData.supplyLimit
    );

    await deployedContract.deployTransaction.wait();

    this.contractAddress = deployedContract.address;
    this.contract = deployedContract;

    console.log("Contract deployed at:", this.contractAddress);
  }

  // Минт токен в коллекции
  async mintNFT(
    wallet: ethers.HDNodeWallet,
    recipient: string,
    metadataURI: string
  ) {
    if (!this.contractAddress || !this.contract) {
      throw new Error("Contract is not deployed");
    }

    const mintTx = await this.contract.connect(wallet).mintNFT(
      this.contractAddress, // ID коллекции или другой идентификатор, если требуется
      recipient,
      metadataURI
    );
    const receipt = await mintTx.wait();
    console.log("NFT minted:", receipt);
  }

  // Получение информации о коллекции
  async getCollectionInfo() {
    if (!this.contractAddress || !this.contract) {
      throw new Error("Contract is not deployed");
    }

    const collectionInfo = await this.contract.getCollectionInfo(
      this.contractAddress
    );
    console.log("Collection Info:", collectionInfo);
    return collectionInfo;
  }

  // Проверка привязки токена к коллекции
  async getCollectionForToken(tokenId: number) {
    if (!this.contractAddress || !this.contract) {
      throw new Error("Contract is not deployed");
    }

    const collectionId = await this.contract.getCollectionForToken(tokenId);
    console.log("Collection ID for Token:", collectionId);
    return collectionId;
  }
}
