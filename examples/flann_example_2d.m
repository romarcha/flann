resolution = 0.005;
[datasetX datasetY] = meshgrid(0:resolution:1,0:resolution:1);
dataset = [datasetX(:)';datasetY(:)'];
testset = [0.50001 0.5001]';
figure;
plot(dataset(1,:),dataset(2,:),'go');
hold on;
plot(testset(1,:),testset(2,:),'ro');
axis ([0 1 0 1 0 1]);

%%
tic;
build_params.algorithm = 'kdtree';
build_params.trees = 1;
flann_set_distance_type(1);
%build_params.target_precision = 0.7;
%build_params.build_weight = 0.01;
%build_params.memory_weight = 0;
[index, parameters] = flann_build_index(dataset, build_params);
[result, dists] = flann_search(index,testset,1000,parameters);
flann_free_index(index);
toc;

%%
n_querys = size(result,2);
nn_num = size(result,1);

for i = 1:n_querys
%    figure;
%    hold on;
%    plot(testset(1,i),testset(2,i),'ro');
    for j = 1:nn_num
        plot(dataset(1,result(j,i)),dataset(2,result(j,i)),'x');
    end
    axis ([0 1 0 1]);
end

figure;
plot(dists);