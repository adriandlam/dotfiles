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
exports.copyLocalDatabaseUrl = copyLocalDatabaseUrl;
exports.copyLocalDatabaseUrlSafely = copyLocalDatabaseUrlSafely;
const vscode_1 = require("vscode");
const PrismaPostgresRepository_1 = require("../PrismaPostgresRepository");
function copyLocalDatabaseUrl(args) {
    return __awaiter(this, void 0, void 0, function* () {
        const item = PrismaPostgresRepository_1.LocalDatabaseSchema.parse(args);
        yield vscode_1.env.clipboard.writeText(item.url);
        void vscode_1.window.showInformationMessage(`PPg Dev URL copied to your clipboard!`);
    });
}
function copyLocalDatabaseUrlSafely(args) {
    return __awaiter(this, void 0, void 0, function* () {
        return copyLocalDatabaseUrl(args);
    });
}
//# sourceMappingURL=copyLocalDatabaseUrl.js.map