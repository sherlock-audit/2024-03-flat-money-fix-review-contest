const fs = require("fs");
const { task } = require("hardhat/config");
const path = require("path");

task("reset-configs", "Resets config values")
    .addParam("path", "The path to the config folder (not file)")
    .addParam("keys", "The path to the file holding the keys to reset")
    .setAction(async (taskArgs, hre) => {
        await hre.run("compile");

        // Define the directory containing the config files
        const configDir = path.join(__dirname, "..", taskArgs.path);

        // Define the keys to be reset.
        // The file should contain an object with the keys to reset in an array.
        const keysToReset = require(path.join(__dirname, "..", taskArgs.keys)).keys;

        try {
            // Loop through each file in the directory
            fs.readdirSync(configDir).forEach((file) => {
                let valuesReset;

                // Load the file as a JSON object
                const filePath = path.join(configDir, file);
                const config = require(filePath);

                // Loop through each key in the object
                for (const key in config) {
                    // If the key is one of the keys to reset, set its value to undefined
                    if (keysToReset.includes(key)) {
                        // Note that we are resetting the value to string 'undefined'
                        // This is because, JSON.stringify will remove the key if the value is undefined.
                        config[key] = "undefined";
                        valuesReset = true;
                    }
                }

                if (valuesReset) {
                    const updatedModuleContents = `module.exports = ${JSON.stringify(config, null, 4)};\n`;

                    // Write the modified object back to the file
                    fs.writeFileSync(filePath, updatedModuleContents);
                }
            });
        } catch (error) {
            console.error("Error resetting config values:", error);
        }
    });
