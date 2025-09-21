import ethers from "ethers";

export type mintParams = {
  recipient: string;
  metadataURI: string;
  contractAddress: string;
};

export class NFT {
  async deploy(wallet: ethers.HDNodeWallet, params: mintParams) {
    if (!params.contractAddress) {
      throw new Error("Contract is not deployed");
    }

    const mintTx = await this.contract.connect(wallet).mintNFT(
      params.contractAddress, // ID коллекции или другой идентификатор, если требуется
      params.recipient,
      params.metadataURI
    );
    const receipt = await mintTx.wait();
    console.log("NFT minted:", receipt);
  }
}
