import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;
  let depositToken = process.env.SALE_TOKEN_ADDRESS;
  let idoToken = process.env.IDO_TOKEN_ADDRESS;

  if (hre.network.name === "localhost") {
    const depositTokenMock = await deploy("DepositTokenMock", {
      from: deployer,
      args: [6],
      log: true,
      autoMine: true,
    });

    const idoTokenMock = await deploy("IDOTokenMock", {
      from: deployer,
      args: [12],
      log: true,
      autoMine: true,
    });

    depositToken = depositTokenMock.address;
    idoToken = idoTokenMock.address;
  }

  await deploy("IDO", {
    from: deployer,
    args: [
      [depositToken],
      ["0x3E7d1eAB13ad0104d2750B8863b489D65364e32D"],
      "50000000000000000",
      "1000000000000000000000",
      "500000000000000000000",
      "5000000000000000000",
      1703239200,
      1703343600,
      idoToken,
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    ],
    log: true,
    autoMine: true,
  });
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags IDO
deployYourContract.tags = ["IDO"];
