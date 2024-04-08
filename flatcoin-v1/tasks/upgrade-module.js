const { task } = require("hardhat/config");
const { retryWithDelay } = require("./utils");

task("upgrade-module", "Upgrades a Flatcoin upgradeable module")
    .addParam("module", "The name of the module to deploy")
    .addParam("proxy", "The address of the proxy to upgrade")
    .setAction(async (taskArgs, hre) => {
        await hre.run("compile");

        const deployer = (await hre.ethers.getSigners())[0];

        console.log(`Deploying ${taskArgs.module} with the account:`, deployer.address);

        const ModuleFactory = await hre.ethers.getContractFactory(taskArgs.module);

        const module = await retryWithDelay(
            async () =>
                await upgrades.upgradeProxy(taskArgs.proxy, ModuleFactory, { redeployImplementation: "onchange" }),
        );

        await module.waitForDeployment();

        const modAddress = await module.getAddress();
        const implementationAddress = await erc1967.getImplementationAddress(hre.ethers.provider, modAddress);

        console.log(`${taskArgs.module} implementation deployed to:`, implementationAddress);

        // Verify the module on Etherscan.
        // NOTE: We are assuming that upgradeable contracts don't have constructor arguments.
        try {
            await retryWithDelay(
                async () =>
                    await hre.run("verify:verify", {
                        address: implementationAddress,
                    }),
            );

            console.log(`${taskArgs.module} implementation at ${implementationAddress} verified!`);
        } catch (error) {
            console.error(`Error encountered while verifying ${taskArgs.module} at ${implementationAddress}:`, error);
        }

        return modAddress;
    });