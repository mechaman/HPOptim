require 'torch'
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

function trainHyper(tab_params) -- change after to just trainHyper... no returning model

  tab_params['numHidden1'] = math.floor(math.pow(10,tab_params['numHidden1']))
  tab_params['numHidden2'] = math.floor(math.pow(10,tab_params['numHidden2']))
  tab_params['numHidden3'] = math.floor(math.pow(10,tab_params['numHidden3']))
  tab_params['numHidden4'] = math.floor(math.pow(10,tab_params['numHidden4']))
  tab_params['numHidden5'] = math.floor(math.pow(10,tab_params['numHidden5']))
  tab_params['numHidden6'] = math.floor(math.pow(10,tab_params['numHidden6']))
  tab_params['numHidden7'] = math.floor(math.pow(10,tab_params['numHidden7']))
  
  	-- Load Data
	local train_data = torch.load("data/b_uniErr_train.txt", 'ascii')
 	local test_data = torch.load("data/b_uniErr_test.txt", 'ascii')
 
 	-- Input/Output Nodes
 	local nInputs = 2
 	local nOutputs = 1
 	local dataset_train = getTableFromTensor(train_data, nInputs, nOutputs)

	-- define the FNN
	local mlp = nn.Sequential()

  -- MLP Construction Logic
  if (tab_params['numHidden1'] == 0) and (tab_params['numHidden2'] == 0) and (tab_params['numHidden3'] == 0) then 
    mlp:add(nn.Linear(nInputs,nOutputs))
  else
    local numBefOutput = nInputs

    if (tab_params['numHidden1'] ~= 0) then
      mlp:add(nn.Linear(numBefOutput, tab_params['numHidden1']))
      mlp:add(nn.Tanh())
      numBefOutput = tab_params['numHidden1']
    end

    if(tab_params['numHidden2'] ~= 0) then
      mlp:add(nn.Linear(numBefOutput, tab_params['numHidden2']))
      mlp:add(nn.Tanh())
      numBefOutput = tab_params['numHidden2']
    end

    if(tab_params['numHidden3'] ~= 0) then
      mlp:add(nn.Linear(numBefOutput, tab_params['numHidden3']))
      mlp:add(nn.Tanh())
      numBefOutput = tab_params['numHidden3']
    end
    mlp:add(nn.Linear(numBefOutput, nOutputs))
  end

 	-- Train the dataset
 	local criterion = nn.MSECriterion()
  	local trainer = nn.StochasticGradient(mlp, criterion)
  	trainer.maxIteration = 400
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
   local mse_avg = 0
   for k,v in pairs(test_y) do
   		mse_arr[k] = criterion:forward(test_y_pred[k], test_y[k])
   		mse_avg = mse_avg + mse_arr[k]
		print("Test MSE:" .. mse_arr[k] )
	end

	mse_avg = mse_avg/10
	return mse_avg
	
end
