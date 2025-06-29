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
exports.handleAuthCallback = exports.login = void 0;
const vscode_1 = require("vscode");
/**
 * This function triggers the OAuth login flow by creating the necessary URL and opening the users browser.
 */
const login = (ppgRepository, auth) => __awaiter(void 0, void 0, void 0, function* () {
    if ((yield ppgRepository.getWorkspaces()).length === 0) {
        yield vscode_1.commands.executeCommand('setContext', 'prisma.initialLoginInProgress', true);
    }
    yield auth.login();
    yield vscode_1.commands.executeCommand('setContext', 'prisma.initialLoginInProgress', false);
});
exports.login = login;
/**
 * This function is called when the extension receives the auth callback from the previously started login flow.
 */
const handleAuthCallback = (_a) => __awaiter(void 0, [_a], void 0, function* ({ uri, ppgRepository, auth, }) {
    try {
        const result = yield auth.handleCallback(uri);
        if (!result)
            return; // received url was not an auth callback
        yield vscode_1.window.withProgress({
            location: vscode_1.ProgressLocation.Notification,
            title: 'Logging in to Prisma workspace...',
        }, () => ppgRepository.addWorkspace({ token: result.token, refreshToken: result.refreshToken }));
        void vscode_1.window.showInformationMessage('Workspace connected!');
    }
    catch (error) {
        console.error(error);
        void vscode_1.window.showErrorMessage('Login to Workspace failed! Please try again.');
    }
});
exports.handleAuthCallback = handleAuthCallback;
//# sourceMappingURL=login.js.map