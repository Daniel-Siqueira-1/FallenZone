local Promise = require(script.Parent.Promise)
export type Trove = {
	Clean: (any)->();
	Destroy: (any)->();
	Extend: (any)->();
	Clone: (any,instance: Instance)->();
	Construct: (any,class:any,...any)->();
	Add: (any,instance: Instance, cleanupMethod: string?)->();
	AddPromise: (any,Promise: Promise.Promise)->();
	Remove: (any, child: any)->(boolean);
	BindToRenderStep: (any,name: string, priority: number, fn: (dt: number)->())->();
}

return require(script.Parent._Index["sleitnick_trove@1.0.0"]["trove"])
