const fs_extra = require("fs-extra")
const { execFileSync } = require("child_process")
const { join } = require("path")
const { parse } = require("toml")
const deletedir = require('rimraf');

const parsedToml = parse(fs_extra.readFileSync(join("Delver", "../wally.toml"), "utf-8"))
const packageWholeName = parsedToml.package.name.replace("/", "_")
const packageVersion = parsedToml.package.version
const packageName = packageWholeName.split("_")[1]

const srcPath = join("Delver", "../src")
const packagesPath = join("Delver", "../Packages")
const integratedPath = join("Delver", "../integrated")
const UserDir = join(integratedPath, `./_Index/${packageWholeName}@${packageVersion}`)
const packageDir = join(UserDir, `./${packageName}`)
const integratedProject = join("Delver", "../integrated.project.json")

fs_extra.mkdirSync(integratedPath)
fs_extra.copySync(packagesPath, integratedPath)
fs_extra.mkdirSync(UserDir)
fs_extra.mkdirSync(packageDir)
fs_extra.copySync(srcPath, packageDir)
fs_extra.writeFileSync(join(integratedPath, `./${packageName}.lua`), `return require(script.Parent._Index["${packageWholeName}@${packageVersion}"]["${packageName}"])`)
fs_extra.writeFileSync(integratedProject, '{"name": "Packages","tree": {"$path" : "integrated"}}')

execFileSync('rojo.exe', ["build", "-o Delver.rbxm", "integrated.project.json"]);
deletedir(integratedPath, (err) => {
    if (err) {
        console.log(err)
    } else {
        deletedir(integratedProject, (s) => {})
        console.log("Built the release and deleted the integrated folder")
    }
});