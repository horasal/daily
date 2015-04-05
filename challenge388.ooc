import structs/ArrayList
import text/StringTokenizer

Tape: class{
    _middle := 0
    _head := 0
    content := ArrayList<Char> new()
    symbols := ArrayList<Char> new()

    middle ::= 0
    head ::= _head - middle

    init: func(s: String, c: String){
        symbols add('_')
        for(i in s){ symbols add(i) }
        for(i in c){ content add(i) }
    }

    valid: func(c: Char) -> Bool{ symbols contains?(c) }

    movel: func -> Char{
        if(_head == 0){
            content add(0, '_')
            _middle = _middle + 1
            return '_'
        }
        content[_head=_head-1]
    }
    mover: func -> Char{
        if(_head == content size - 1){ content add('_') }
        content[_head=_head+1]
    }
    read: func -> Char{ content[_head] }
    write: func(c: Char) -> Char{
        content[_head] = c
        c
    }

    symbolize: func -> String{
        r := ""
        for(i in symbols){
            r += i
            r += ", "
        }
        r
    }

    toString: func -> String{
        r := ""
        for(i in content){ r = r + i }
        if(_middle == _head){
            r += "\n" + (_middle > 0 ? " " times(_middle) : "") + "|"
        } else {
            if(_head > _middle){
                r += "\n" + (_middle > 0 ? " " times(_middle) : "") + "|"
                r += (_head - _middle - 1 > 0 ? " " times(_head - _middle - 1)  : "") + "^"
            } else {
                r += "\n" + (_head > 0 ? " " times(_head) : "") + "|"
                r += (_middle - _head - 1> 0 ? " " times(_middle - _head - 1)  : "") + "^"
            }
        }
        r
    }
}

Rule: class{
    statef: String
    contentf: Char
    statet: String
    contentt: Char
    movement: Char

    init: func(=statef, =contentf, =statet, =contentt, =movement)

    matches?: func(state: String, content: Char) -> Bool{
        statef == state && contentf == content
    }

    apply: func(m: Machine) {
        m currentState = statet
        m tape write(contentt)
        _move(m tape) 
    }

    _move: func(tape: Tape){
        match(movement){
            case '>' => tape mover()
            case '<' => tape movel()
            case => Exception new("Incorrent Tape Movement") throw()
        }
    }

    toString: func -> String{
        "f(%s, %c) = {%s, %c, %c}" format(statef, contentf, statet, contentt, movement)
    }
}

Machine: class{
    states := ArrayList<String> new()
    currentState: String
    acceptState: String
    rules := ArrayList<Rule> new()

    tape: Tape

    init: func(s: String, =currentState, =acceptState){ states = s split(" ") }

    validate: func -> Bool{ states contains?(currentState) }
    finish?: func -> Bool{ currentState == acceptState }

    findRule: func -> Rule{
        for(i in 0..rules size){
            if(rules[i] matches?(currentState, tape read())){
                return rules[i]
            }
        }
        Exception new("Machine lacks Rule!") throw()
        null
    }

    run: func{
        while(true){
            if(finish?()) break
            findRule() apply(this)
            if(!validate()) Exception new("Machine broken") throw()
        }
    }

    symbolize: func -> String{
        r := ""
        for(i in states){ r += i + ", " }
        r
    }

    toString: func -> String{
        r := "Machine(c, s, f){\n"
        r += "\tc = (%s)\n" format(tape symbolize())
        r += "\ts = (%s)\n" format(symbolize())
        r += "\tf = (\n" 
        for(rule in rules){ r += "\t\t" + rule toString()+"\n" }
        r += "\t)\n"
        r += "\tstate = %s, target = %s\n" format(currentState, acceptState)
        r = r+"}\n"
        r += tape toString()
        r 
    }

}

main: func -> Int{
    m := Machine new("Mov B Bi OK", "Mov", "OK")
    m tape = Tape new("01", "01100100")

    m rules add(Rule new("Mov", '0', "Mov", '0', '>'))
    m rules add(Rule new("Mov", '1', "Mov", '1', '>'))
    m rules add(Rule new("Mov", '_', "B", '_', '<'))
    m rules add(Rule new("B", '0', "B", '0', '<'))
    m rules add(Rule new("B", '1', "Bi", '1', '<'))
    m rules add(Rule new("B", '_', "OK", '_', '>'))
    m rules add(Rule new("Bi", '0', "Bi", '1', '<'))
    m rules add(Rule new("Bi", '1', "Bi", '0', '<'))
    m rules add(Rule new("Bi", '_', "OK", '_', '>'))

    m run()
    m toString() println()

    m2 := Machine new("C0 C1 Ret Search OK", "Search", "OK")
    m2 tape = Tape new("01xy#", "0110100#")

    m2 rules add(Rule new("Search", '0', "C0", 'x', '>'))
    m2 rules add(Rule new("Search", '1', "C1", 'y', '>'))
    m2 rules add(Rule new("Search", '#', "OK", '#', '>'))
    m2 rules add(Rule new("C0", '0', "C0", '0', '>'))
    m2 rules add(Rule new("C0", '1', "C0", '1', '>'))
    m2 rules add(Rule new("C0", '#', "C0", '#', '>'))
    m2 rules add(Rule new("C0", '_', "Ret", '0', '<'))
    m2 rules add(Rule new("C1", '0', "C1", '0', '>'))
    m2 rules add(Rule new("C1", '1', "C1", '1', '>'))
    m2 rules add(Rule new("C1", '#', "C1", '#', '>'))
    m2 rules add(Rule new("C1", '_', "Ret", '1', '<'))
    m2 rules add(Rule new("Ret", '0', "Ret", '0', '<'))
    m2 rules add(Rule new("Ret", '1', "Ret", '1', '<'))
    m2 rules add(Rule new("Ret", '#', "Ret", '#', '<'))
    m2 rules add(Rule new("Ret", 'x', "Search", '0', '>'))
    m2 rules add(Rule new("Ret", 'y', "Search", '1', '>'))

    m2 run()
    m2 toString() println()

    m3 := Machine new("Init Mdot MDash Ret OK", "Init", "OK")
    m3 tape = Tape new("./k", "/././../.../..../k")
    m3 rules add(Rule new("Init", '_', "Init", '_', '>'))
    m3 rules add(Rule new("Init", '.', "Mdot", '_', '>'))
    m3 rules add(Rule new("Init", '/', "MDash", '_', '>'))
    m3 rules add(Rule new("Init", 'k', "OK", 'k', '>'))
    m3 rules add(Rule new("Mdot", '.', "Mdot", '.', '>'))
    m3 rules add(Rule new("Mdot", '/', "Mdot", '/', '>'))
    m3 rules add(Rule new("Mdot", 'k', "Mdot", 'k', '>'))
    m3 rules add(Rule new("Mdot", '_', "Ret", '.', '<'))
    m3 rules add(Rule new("MDash", '.', "MDash", '.', '>'))
    m3 rules add(Rule new("MDash", '/', "MDash", '/', '>'))
    m3 rules add(Rule new("MDash", 'k', "MDash", 'k', '>'))
    m3 rules add(Rule new("MDash", '_', "Ret", '/', '<'))
    m3 rules add(Rule new("Ret", '.', "Ret", '.', '<'))
    m3 rules add(Rule new("Ret", '/', "Ret", '/', '<'))
    m3 rules add(Rule new("Ret", 'k', "Ret", 'k', '<'))
    m3 rules add(Rule new("Ret", '_', "Init", '_', '>'))

    m3 run()
    m3 toString() println()

    0
}
