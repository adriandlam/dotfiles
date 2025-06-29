const vscode = require("vscode")
const path = require("path")
const fs = require("fs")

const FILENAME = "smearcursor.js"

function reload() {
	vscode.commands.executeCommand("extension.updateCustomCSS");
	setTimeout(function () {
		vscode.commands.executeCommand('workbench.action.reloadWindow');
	}, 500);
}

function create_script() {
	const src = path.join(__dirname, FILENAME)
	if (!fs.existsSync(src)) return;
	const target = path.join(__dirname, "_" + FILENAME)

	let content = fs.readFileSync(src, "utf-8")
	const regex = /("|')%<.*?>%("|')/gms
	let match = content.match(regex)
	if (match) {
		match.forEach((m) => {
			let setting = m.slice(3, -3).split(".")
			let value = vscode.workspace.getConfiguration(setting[0]).get(setting[1])
			content = content.replace(m, value)
		})
	}

	fs.writeFileSync(target, content)
}

function update_imports(just_delete = false) {
	const conf = vscode.workspace.getConfiguration()
	let imports = conf.vscode_custom_css.imports

	const new_imports = []
	imports.forEach(f => {
		if (f === null) return
		if (f.includes("_" + FILENAME)) return;
		new_imports.push(f)
	});

	if (!just_delete) {
		const target = path.join(__dirname, "_" + FILENAME)
		new_imports.push(`file://${target}`)
	}

	conf.update(
		"vscode_custom_css.imports",
		new_imports,
		vscode.ConfigurationTarget.Global
	)
}

function enable(ctx) {
	disable(ctx, false)
	create_script()
	update_imports(false)
	reload()
}

function disable(ctx, do_reload = true) {
	update_imports(true)
	if (do_reload) reload()
}

exports.activate = function (ctx) {
	ctx.subscriptions.push(vscode.commands.registerCommand('smearcursor.enable', enable))
	ctx.subscriptions.push(vscode.commands.registerCommand('smearcursor.disable', disable))
}
