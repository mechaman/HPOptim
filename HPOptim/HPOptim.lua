--[[
    # Author: Julien Hoachuck
    # Copyright 2015, Julien Hoachuck, All rights reserved.
]]--
local HPOptim = {}
--HPOptim.params = {}

---------------------------------------------------------------------
-- String Splitting --
local function split(str, sep)
    sep = sep or ','
    fields={}
    local matchfunc = string.gmatch(str, "([^"..sep.."]+)")
    if not matchfunc then return {str} end
    for str in matchfunc do
        table.insert(fields, str)
    end
    return fields
end
---------------------------------------------------------------------

function HPOptim.init(dir_p)
	HPOptim['dir_path'] = dir_p -- set the directory path to the folder containing the config/model
	
    print("Initializing...")

    ------- GET PARAMETERS FROM JSON
    local jsonFile = io.open(dir_p.."/config.json")
    io.input(jsonFile)
    local jsonContent = jsonFile:read("*all")
    
    local varBlock = string.match(jsonContent, '"variables"%s:%s%b{}')
    varBlock = string.match(varBlock,'%b{}')
    print(varBlock)
    local paramNamesQuotes = string.gmatch(varBlock, '"[%a*%d*]+" : {')
 
        
    local paramNames = {}
    for nameQuotes in paramNamesQuotes do
        paramNames[string.match(nameQuotes,'[%a*%d*]+')] =  0
    end
    HPOptim.params = paramNames
    print("List of parameters in config.json: ")
    for k,v in pairs(HPOptim.params) do 
        print(k)
    end

    HPOptim.params['error'] = 0
   
    io.close(jsonFile)
end

function HPOptim.clean()
    os.execute("bash "..HPOptim.dir_path.."/HPOptim/clean_up.sh")
end


function HPOptim.getHP()


    local handle = io.popen("ls "..HPOptim.dir_path.."/output")
    local result = handle:read("*a")
    handle:close()

    local filenames = split(result, '\n')

    -- Take each file name and parse out the important values
    for k,v in pairs(filenames) do 
    -- Put into its own function
        local file = io.open(HPOptim.dir_path.."/output/"..v,"r") -- remember to prepend the whole path
        io.input(file)
        local content = file:read("*all")
        io.close(file)

        print("Filename: ".. v)
        
        local keyset={}
        local n=0
        for k,v in pairs(HPOptim.params) do
            n=n+1
            keyset[n]=k
        end
    
        for i=1,table.getn(keyset) do
           HPOptim.params[keyset[i]] = string.match(content,keyset[i]..'[\n].?[%d%.]+')
        end
        -- Take the final value out
        local cost = string.match(content, 'Got result ([%d%.]+)')
        HPOptim.params['error'] = cost

        for k,v in pairs(HPOptim.params) do
            print(k,v)
        end
    end
end

function HPOptim.findHP(time)
    -- put these in a script and then pass it argument HPOptim.dir_path... easier for people to change the locations of files etc.
    os.execute("mongod --fork --logpath $HOME/Desktop/log --dbpath /data/db")
    os.execute("timeout "..time.."s python $HOME/Desktop/Spearmint/Spearmint/spearmint/main.py "..HPOptim.dir_path..">/dev/null") 
    --HPOptim.getHP()
end

function HPOptim.export2CSV()
end

return HPOptim