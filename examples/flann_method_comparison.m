%%  Method Comparison
%   This file is intented to compare different methods for searching
%   nearest neighbors. The idea is to compare within FLANN library options
%   (kd_tree, kmeans and linear search) and also among existing Matlab ones
%   and pure brute force linear search implemented by the author in Matlab.
%
%   The methods will be compared for Number of Datapoints, dimention of the
%   data and NN number.

%% Number of datapoints
function running_time = flann_method_comparison
%% 
% Create data

% Number of datapoints for testing
data_points = linspace(10,5e4,100);
methods = {'my_linear','linear','kdtree'};

% Repetitions of each experiment to get mean and std deviation of results
repetitions = 1;

running_time = zeros(length(methods),length(data_points));

function time = evaluateMethod(number_of_data_points,method)
    resolution = number_of_data_points^(1/3);
    max_range = 1;
    min_range = 0;
    [datasetX datasetY datasetZ] = meshgrid(min_range:(max_range-min_range)/resolution:max_range,min_range:(max_range-min_range)/resolution:max_range,min_range:(max_range-min_range)/resolution:max_range);
    if(size(datasetX,1)*size(datasetX,2)*size(datasetX,3)>3e7)
        error('Too much data!');
    end
    dataset = [datasetX(:)';datasetY(:)';datasetZ(:)'];
    %randomize the order of dataset
    randomIndexes = randsample(size(dataset,2),size(dataset,2));
    dataset = dataset(:,randomIndexes);

    testset = [0.5001;0.5001;0.5001];%rand(3,2);
    
    knn = min(500,floor(number_of_data_points/2));
    
    if(strcmp(method,'linear') || strcmp(method,'kdtree'))
        build_params.algorithm = method;
        build_params.trees = 1;
        flann_set_distance_type(1);
        tic;
        [index, parameters] = flann_build_index(dataset, build_params);
        %tic;
        [result, dists] = flann_search(index,testset,knn,parameters);
        time = toc;
        flann_free_index(index);
    elseif (strcmp(method,'my_linear'))
        tic;
        dist = zeros(1,length(dataset));
        for m = 1:length(dataset)
            dist(m) = norm(dataset(:,m)-testset,2);
        end
        [~,idx] = sort(dist);
        result = dataset(:,idx(1:knn));
        time = toc;
    end
end

for i = 1:length(methods)
    for j = 1:length(data_points)
        fprintf('%f\n',100*((i-1)*length(data_points)+j)/(length(methods)*length(data_points)));
        values = zeros(1,repetitions);
        for k = 1:repetitions
            values(k) = evaluateMethod(data_points(j),methods{i});
        end
        running_time(i,j) = mean(values);
    end
end

%%
% Plot Results

h(1) = plot(data_points,running_time(1,:),'r');
hold on;
h(2) = plot(data_points,running_time(2,:));
h(3) = plot(data_points,running_time(3,:),'g');
legend(h,methods{1},methods{2},methods{3}, 'Location','NorthWest')

end