type PromiseFunction = (resolve: (...any)->(), reject: (...any)->(), cancel: (...any)->())->(...any)

export type Status = "Started" | "Resolved" | "Rejected" | "Cancelled"

export type PromiseChain<Return> = any & {
    andThen: (any,callback: PromiseFunction)->PromiseChain<Return>;
    finally: (any, finallyHandler: (Status: Status)->...any)->PromiseChain<Return>;
    await: (any)->(boolean, ...any);
    cancel: (any)->();
    catch: (failureHandler: (...any)-> ...any)->PromiseChain<Return>;
}

export type Promise = {
    is: (yourObject: any)->boolean;
    new: (yourFunction: PromiseFunction)->PromiseChain<any>;
    allSettled: (promises: {PromiseChain<any>})->PromiseChain<{Status}>
}

export type resolve<input>  = (input)->()
export type reject<input> = (input)->()

return require(script.Parent._Index["evaera_promise@4.0.0"]["promise"]) :: Promise