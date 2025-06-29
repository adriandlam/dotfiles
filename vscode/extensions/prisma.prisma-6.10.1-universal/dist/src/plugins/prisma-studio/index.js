"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const launch_1 = require("./commands/launch");
exports.default = {
    name: 'Studio',
    enabled() {
        return true;
    },
    activate(context) {
        context.subscriptions.push(vscode_1.commands.registerCommand('prisma.studio.launch', () => (0, launch_1.launch)({ context })));
    },
    deactivate() { },
};
//# sourceMappingURL=index.js.map