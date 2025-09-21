import { ethers } from "ethers";

export async function openWallet(
  mnemonic: string[]
): Promise<ethers.HDNodeWallet> {
  const url =
      process.env.MODE === "dev"
        ? "https://data-seed-prebsc-1-s1.binance.org:8545/" // Testnet URL
        : "https://bsc-dataseed.binance.org/";
  const provider = new ethers.JsonRpcProvider(
    url
  );

  const wallet = ethers.Wallet.fromPhrase(mnemonic.join(" "));

  return wallet.connect(provider);
}
