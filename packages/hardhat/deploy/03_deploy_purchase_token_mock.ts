import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("IDOTokenMock", {
    from: deployer,
    args: [6],
    log: true,
    autoMine: true,
  });
};

export default deploy;

deploy.tags = ["IDOTokenMock", "mocks"];
