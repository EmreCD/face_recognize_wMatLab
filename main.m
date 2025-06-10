clc; clear; close all;

faceDetector = vision.CascadeObjectDetector();

faces = [];
labels = [];
personList = {};
dataPath = 'data';
people = dir(dataPath);

for i = 3:length(people)
    personName = people(i).name;
    personDir = fullfile(dataPath, personName);
    images = dir(fullfile(personDir, '*.jpg')); % sadece .jpg

    personList{end+1} = personName;
    label = length(personList);  

    for j = 1:length(images)
        imgPath = fullfile(personDir, images(j).name);
        fprintf('Yükleniyor: %s\n', imgPath);
        img = imread(imgPath);

        bbox = step(faceDetector, img);
        if isempty(bbox)
            continue;
        end

        % Birden fazla yüz varsa ilkini al
        box = bbox(1,:);
        % Çok küçük yüzleri atla
        if box(3) < 50 || box(4) < 50
            continue;
        end

        face = imcrop(img, box);
        face = imresize(rgb2gray(face), [100 100]);
        faces = [faces; double(face(:)')];
        labels = [labels; label];
    end
end

%PCA boyut indirgeme
fprintf('PCA\n');
[coeff, score, ~] = pca(faces);
numComponents = min(50, size(score, 2));
X_train = score(:, 1:numComponents);

% SVM 
fprintf('Model eğitiliyor...\n');
svmTemplate = templateSVM('KernelFunction','linear','Standardize',true);
svmModel = fitcecoc(X_train, labels, 'Learners', svmTemplate);


while true
    % Test resmi seç
    [testFile, testPath] = uigetfile('*.jpg', 'Test resmi seçin');
    if isequal(testFile, 0)
        disp('Dosya seçilmedi. Çıkılıyor');
        break;
    end

    testImg = imread(fullfile(testPath, testFile));
    bbox = step(faceDetector, testImg);
    if isempty(bbox)
        warning('Yüz bulunamadı.');
        continue;
    end

    box = bbox(1,:);
    if box(3) < 50 || box(4) < 50
        warning('Tespit edilen yüz çok küçük.');
        continue;
    end

    faceTest = imcrop(testImg, box);
    faceTest = imresize(rgb2gray(faceTest), [100 100]);
    faceVec = double(faceTest(:)');

    facePCA = (faceVec - mean(faces)) * coeff(:, 1:numComponents);
    predictedLabel = predict(svmModel, facePCA);
    predictedName = personList{predictedLabel};

    imshow(testImg);
    title(['Tahmin: ', predictedName], 'FontSize', 14);
    fprintf('Tahmin edilen kişi: %s\n', predictedName);

    choice = questdlg('Devam etmek istiyor musunuz?', ...
        'Tahmin tamamlandı', ...
        'Evet', 'Hayır', 'Evet');

    if strcmp(choice, 'Hayır')
        break;
    end
end
