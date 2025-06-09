clc; clear;

% bazı resimlerin uzantısı jpg yapmama rağmen gerçekte jpg olmuyordu
% bu durumu test etmek ve modeli doğru eğitmek için resimlerin jpg olma
% durumunu test ettim. farklı dosya türleri modelin skorunu etkileyebilir
% mi araştırıcam
rootFolder = 'data';
people = dir(rootFolder);

for i = 3:length(people)
    personName = people(i).name;
    personDir = fullfile(rootFolder, personName);
    imageFiles = dir(fullfile(personDir, '*.jpg'));
    
    for j = 1:length(imageFiles)
        imgPath = fullfile(personDir, imageFiles(j).name);
        try
            imfinfo(imgPath); % Geçerli format mı?
        catch
            fprintf('❌ HATALI: %s\n', imgPath);
        end
    end
end