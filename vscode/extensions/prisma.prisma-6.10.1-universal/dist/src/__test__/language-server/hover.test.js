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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = __importDefault(require("vscode"));
const assert_1 = __importDefault(require("assert"));
const helper_1 = require("../helper");
function testHover(docUri, position, expectedHover) {
    return __awaiter(this, void 0, void 0, function* () {
        const actualHover = yield vscode_1.default.commands.executeCommand('vscode.executeHoverProvider', docUri, position);
        assert_1.default.ok(actualHover.length === 1);
        assert_1.default.ok(actualHover[0].contents.length === 1);
        const result = actualHover[0].contents[0];
        assert_1.default.deepStrictEqual(result.value, expectedHover);
    });
}
suite('Should show /// documentation comments for', () => {
    const docUri = (0, helper_1.getDocUri)('hover/schema.prisma');
    const expectedHover = `\`\`\`prisma\nmodel Post {\n\t...\n\tauthor User? @relation(name: "PostToUser", fields: [authorId], references: [id])\n}\n\`\`\`\n___\none-to-many\n___\nPost including an author and content.`;
    test('model', () => __awaiter(void 0, void 0, void 0, function* () {
        yield (0, helper_1.activate)(docUri);
        yield testHover(docUri, new vscode_1.default.Position(23, 10), expectedHover);
    }));
});
//# sourceMappingURL=hover.test.js.map