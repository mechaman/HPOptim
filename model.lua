--require 'torch'
require 'nn'
require 'cephes'

-----------------------------------------
function getTableFromTensor(teData, nInputs, nOutputs)

    local train_X = teData[1] -- take the first two columns as X
    local train_y = teData[2] -- take the last column as y

   local tableData = {}
   function tableData:size() return train_X[1]:size(1) end

   for i=1, 100 do
     tableData[i] = { train_X:narrow(1,i,1), train_y:narrow(1,i,1) }
   end
   
   return tableData
end
-----------------------------------------
local model = {}

function model.trainHyper(tab_params) -- change after to just trainHyper... no returning model
	-- Load Data
	local train_data = torch.load("b_uniErr_train.txt", 'ascii')
 	local test_data = torch.load("b_uniErr_test.txt", 'ascii')
 

 	-- Input/Output Nodes
 	local nInputs = 2
 	local nOutputs = 1
 	local dataset_train = getTableFromTensor(train_data, nInputs, nOutputs)

 	-- define the FNN
  	local mlp = nn.Sequential()
  	mlp:add(nn.Linear(nInputs, tab_params))
  	mlp:add(nn.Tanh())
 	mlp:add(nn.Linear(tab_params, nOutputs))

 	-- Train the dataset
 	local criterion = nn.MSECriterion()
  	local trainer = nn.StochasticGradient(mlp, criterion)
  	trainer.maxIteration = 400
  	--trainer.learningRate = 0.01
  	trainer.verbose = false
  	trainer:train(dataset_train)

   local test_X = {}
   local test_y = {}
   for i=1, 10 do
    test_X[i] = test_data[1]:narrow(1,i,1)
    test_y[i] = test_data[2]:narrow(1,i,1)
   end

   local test_y_pred = {}
   for k,v in pairs(test_X) do
   		test_y_pred[k] = mlp:forward(v)
   end

   local mse_arr = {}
   for k,v in pairs(test_y) do
   		mse_arr[k] = criterion:forward(test_y_pred[k], test_y[k])
		print("Test MSE:" .. mse_arr[k] )
	end
	
end



return model