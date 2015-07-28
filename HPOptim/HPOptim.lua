--[[
    # Author: Julien Hoachuck
    # Copyright 2015, Julien Hoachuck, All rights reserved.
]]--
local HPOptim = {}
HPOptim.params = {}

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

function HPOptim.init()
    current_dir=io.popen"pwd":read'*l'
    print(current_dir)
	HPOptim['dir_path'] = current_dir -- set the directory path to the folder containing the config/model
	
    print("Initializing...")

    ------- GET PARAMETERS FROM JSON
    local jsonFile = io.open(HPOptim.dir_path.."/config.json")
    io.input(jsonFile)
    local jsonContent = jsonFile:read("*all")
    
    local varBlock = string.match(jsonContent, '"variables"%s:%s%b{}')
    varBlock = string.match(varBlock,'%b{}')
    local paramNamesQuotes = string.gmatch(varBlock, '"[%a*%d*]+" : {')
 
        
    local paramNames = {}
    for nameQuotes in paramNamesQuotes do
        paramNames[string.match(nameQuotes,'[%a*%d*]+')] =  0
    end
    HPOptim.params = paramNames

    HPOptim.params['error'] = 0
   
    io.close(jsonFile)
end

function HPOptim.clean()
    os.execute("bash "..HPOptim.dir_path.."/HPOptim/clean_up.sh")
end


function HPOptim.getHP()
    print("Getting Hyperparameters!")

    local handle = io.popen("ls "..HPOptim.dir_path.."/output")
    local result = handle:read("*a")
    handle:close()

    local filenames = split(result, '\n')

    local cost = 1000
    -- Take each file name and parse out the important values
    for k,v in pairs(filenames) do 
    -- Put into its own function
        local file = io.open(HPOptim.dir_path.."/output/"..v,"r")
        io.input(file)
        local content = file:read("*all")
        io.close(file)
     
        print(string.match(content, 'Got result ([%d%.]+)'))
        
        if cost >= tonumber(string.match(content, 'Got result ([%d%.]+)')) then -- if current result smaller then assign
            local keyset={}
            local n=0
            for k,v in pairs(HPOptim.params) do
                n=n+1
                keyset[n]=k
            end
            
            for i=1,table.getn(keyset) do
              if keyset[i] == "error" then
                
              else
                local withAlpha =  string.match(content,keyset[i]..'[\n].?[%d%.]+')
                HPOptim.params[keyset[i]] = tonumber(string.match(withAlpha,'[%d%.]+'))
              end 
            end

            cost = tonumber(string.match(content, 'Got result ([%d%.]+)'))
       		HPOptim.params['error'] = cost

        end
        -- Take the final value out
        --cost = tonumber(string.match(content, 'Got result ([%d%.]+)'))
        --HPOptim.params['error'] = cost
  
    end
end

function HPOptim.findHP(time)
    -- put these in a script and then pass it argument HPOptim.... easier for people to change the locations of files etc.
    os.execute("mongod --fork --logpath $HOME/Desktop/log --dbpath /data/db")
    os.execute("timeout "..time.."s python $HOME/Desktop/Spearmint/spearmint/main.py "..HPOptim.dir_path) 
    HPOptim.getHP()
end

function HPOptim.export2CSV()
end

return HPOptim