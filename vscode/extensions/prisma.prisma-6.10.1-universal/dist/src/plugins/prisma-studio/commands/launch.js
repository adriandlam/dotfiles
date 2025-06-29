"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.launch = launch;
const vscode_1 = require("vscode");
const openNewStudioTab_1 = require("./launch/openNewStudioTab");
/**
 * Launches Prisma Studio, prompting for a database URL if not provided.
 * @param args - An object containing the database URL and extension context.
 */
function launch(args) {
    return __awaiter(this, void 0, void 0, function* () {
        const { dbUrl } = args;
        if (dbUrl === undefined) {
            const dbUrl = yield vscode_1.window.showInputBox({
                prompt: 'Enter your Prisma Postgres database URL',
                placeHolder: 'e.g., prisma+postgres://accelerate.prisma-data.net/?api_key=xxx',
            });
            // TODO: improve URL validation
            if (dbUrl === undefined || dbUrl === '') {
                return vscode_1.window.showErrorMessage('A valid URL is required to launch Prisma Studio.');
            }
            return (0, openNewStudioTab_1.openNewStudioTab)(Object.assign(Object.assign({}, args), { dbUrl }));
        }
        return (0, openNewStudioTab_1.openNewStudioTab)(Object.assign(Object.assign({}, args), { dbUrl }));
    });
}
//# sourceMappingURL=launch.js.map