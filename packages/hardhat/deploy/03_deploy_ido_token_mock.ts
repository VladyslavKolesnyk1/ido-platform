import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("PurchaseTokenMock", {
    from: deployer,
    args: [18],
    log: true,
    autoMine: true,
  });
};

export default deploy;

deploy.tags = ["PurchaseTokenMock", "mocks"];
