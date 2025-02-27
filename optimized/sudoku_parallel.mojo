from time import now
from math import iota
from algorithm import parallelize

#INFO: optimized algo, with specialized types & parallelization

alias GROUP = SIMD[DType.uint8, 16]   # reality is 9, but should be a **2 .. so 16 !

@value
struct Grid:
    var data: Buffer[81, DType.uint8]

    fn __init__(inout self:Grid, g:String) -> None:
        "Create from a string (of 81 chars)."
        let dtp = DTypePointer[DType.uint8].alloc(81)
        self.data = Buffer[81, DType.uint8](dtp)
        let ptr = g._buffer.data.bitcast[UInt8]()
        @unroll
        for idx in range(81):
            self.data[idx] = ptr[idx]-48 if ptr[idx]!=46 else 0
        _=g

    fn __init__(inout self, clone:Grid, idx:Int,c:UInt8) -> None:
        "Clone the grid 'clone', by replacing char at index 'idx' by 'c' one."
        #use stack_allocation
        self.data = Buffer[81, DType.uint8].stack_allocation()
        for i in range(82):
            self.data[i] = clone.data[i]
        self.data[idx]=c

    fn __init__(inout self:Grid) -> None:
        "Create a bad one."
        
        let dtp = DTypePointer[DType.uint8].alloc(1)
        self.data = Buffer[81, DType.uint8](dtp)
        #self.data = Buffer[81, DType.uint8].stack_allocation()
        self.data[0]=-1

    fn is_valid(self:Grid) -> Bool:
        return self.data[0]!=-1

    # fn __del__(owned self:Grid):
    #     return self.dtp.free()

    fn sqr(self:Grid,x:Int,y:Int) -> GROUP:
        let off=y*9+x
        var group=GROUP().splat(0)
        @unroll
        for i in range(3):
            group[i]=self.data[off+i]
            group[i+3]=self.data[off+i+9]
            group[i+6]=self.data[off+i+18]
        return group

    fn col(self:Grid,x:Int) -> GROUP:
        var group=GROUP().splat(0)
        @unroll
        for i in range(9):
            group[i]=self.data[i*9+x]
        return group

    fn row(self:Grid,y:Int) -> GROUP:
        let off=y*9
        var group=GROUP().splat(0)
        @unroll
        for i in range(9):
            group[i]=self.data[off+i]
        return group

    fn free(self:Grid,x:Int,y:Int) -> InlinedFixedVector[UInt8,9]:
        "Returns a string of numbers that can be fit at (x,y)."
        let _s = self.sqr((x//3)*3,(y//3)*3)
        let _c = self.col(x)
        let _r = self.row(y)

        var avails = InlinedFixedVector[UInt8,9](9)
        @unroll
        for c in range(1,10):
            if (not (_s==c).reduce_or()) and (not (_c==c).reduce_or()) and (not (_r==c).reduce_or()):
                # no C in row/col/sqr
                avails.append( c )

        return avails

    
    fn solve(self:Grid) -> Grid:
        var ibest:Int=-1
        var cbest=InlinedFixedVector[UInt8,9](9)
        @unroll
        for i in range(1,10):
            cbest.append(i)
        
        for i in range(81):
            if self.data[i]==0:
                let avails=self.free(i%9,i//9)
                if len(avails)==0:
                    return Grid()   # bad
                else:
                    if len(avails) < len(cbest):
                        ibest=i
                        cbest=avails
                        
                        if len(avails)==1:
                            break
            
            
        if ibest != -1:
            for idx in range(len(cbest)):
                let ng=Grid( self, ibest, cbest[idx].__int__()).solve()
                if ng.is_valid(): return ng^
            return Grid() # bad
        else:
            return self

    fn to_string(self:Grid) -> String:
        var str=String("")
        @unroll
        for i in range(81):
            let c = self.data[i].__int__()
            str+= chr(48+c)[0] if c else "."
        return str 

#alias workers = 4

fn main() raises:
    let buf = open("../grids.txt", "r").read()
    let t=now()

    @parameter
    fn in_p(i:Int):
        let g=Grid(buf[i*82:i*82+81])
        let gg=g.solve()
        print( gg.to_string() )
        
    parallelize[in_p](1956,1956) #more workers to distribute the effort on cores
    print("Took:",(now() - t)/1_000_000_000,"s")
    
    _=buf^ #extend lifetime of pointer
