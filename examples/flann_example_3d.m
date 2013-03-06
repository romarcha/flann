make_plot = 0; %%Make plot of results or not

number_of_data_points = 1e6;% Works for Linear but not with kdtree 2e7;
resolution = number_of_data_points^(1/3);
max = 1;
min = 0;
[datasetX datasetY datasetZ] = meshgrid(min:(max-min)/resolution:max,min:(max-min)/resolution:max,min:(max-min)/resolution:max);
if(size(datasetX,1)*size(datasetX,2)*size(datasetX,3)>3e7)
    error('Too much data!');
end
dataset = [datasetX(:)';datasetY(:)';datasetZ(:)'];
%randomize the order of dataset
randomIndexes = randsample(size(dataset,2),size(dataset,2));
dataset = dataset(:,randomIndexes);
    
testset = [0.5001;0.5001;0.5001];%rand(3,2);
if(make_plot)
    figure;
    plot3(dataset(1,:),dataset(2,:),dataset(3,:),'go');
    hold on;
    plot3(testset(1,:),testset(2,:),testset(3,:),'ro');
    axis ([0 1 0 1 0 1]);
end
%%

build_params.algorithm = 'linear';
build_params.trees = 1;
flann_set_distance_type(1);
[index, parameters] = flann_build_index(dataset, build_params);
tic;
[result, dists] = flann_search(index,testset,500,parameters);
flann_free_index(index);
toc;

%%
make_plot_results = 1;
if(make_plot_results)
    n_querys = size(result,2);
    nn_num = size(result,1);
    hold on;
    for i = 1:n_querys
        hold on;
        plot3(testset(1,i),testset(2,i),testset(3,i),'ro');
        for j = 1:nn_num
            plot3(dataset(1,result(j,i)),dataset(2,result(j,i)),dataset(3,result(j,i)),'x');
        end
        axis ([0 1 0 1 0 1]);
    end

    figure;
    plot(dists);
end