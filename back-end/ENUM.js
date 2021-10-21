const MSG = Object.freeze({
    INVITE_REQUEST: 0,
    USER_JOINS_LIST: 1,
    USER_LEAVES_LIST: 2,
    NEW_BODY_ITEM: 3,
    REMOVE_BODY_ITEM: 4,
    EDIT_BODY_ITEM: 5,
    LOGOUT: 6,
});
exports.MSG = MSG

const POST = Object.freeze({
    SUCCESS: 0,
    INVALID_LOGIN: 1,
    INVALID_REQUEST: 2,
    SERVER_ERROR: 3
});
exports.POST = POST
