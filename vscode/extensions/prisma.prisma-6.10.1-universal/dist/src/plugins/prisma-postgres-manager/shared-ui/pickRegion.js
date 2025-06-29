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
exports.pickRegion = void 0;
const vscode_1 = require("vscode");
const handleCommandError_1 = require("./handleCommandError");
const pickRegion = (regions) => __awaiter(void 0, void 0, void 0, function* () {
    const items = regions.map((r) => ({ region: r, label: `${r.name} (${r.id})`, iconPath: new vscode_1.ThemeIcon('globe') }));
    const selectedItem = yield vscode_1.window.showQuickPick(items, {
        placeHolder: 'Select the region for the database in this new project',
    });
    if (!selectedItem)
        throw new handleCommandError_1.CommandAbortError('Region is required');
    return selectedItem.region;
});
exports.pickRegion = pickRegion;
//# sourceMappingURL=pickRegion.js.map