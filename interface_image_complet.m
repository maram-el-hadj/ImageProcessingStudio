clc;
clear;
close all;

% 1. Lecture de l'image
img = imread('BIRD.BMP');
if size(img, 3) == 3
    img_gray = rgb2gray(img); % Sigur li hiya gray
else
    img_gray = img;
end
[hauteur, largeur] = size(img_gray);

disp('=== ANALYSE DE L''IMAGE ===');
disp(['Taille : ', num2str(largeur), ' x ', num2str(hauteur)]);

% 2. Rotation et Inversion
angle = input('Quel est l''angle de rotation ? ');
img_rot_f = imrotate(img_gray, 90); % Rotation fixe 90°
img_rot_v = imrotate(img_gray, angle); % Rotation b l'angle li dakhaltou (marra wa7da)
img_inv = 255 - img_gray; % Inversion des couleurs

% 3. Sélection de Bloc (Zone)
disp('--- Sélection de la zone ---');
ligne_debut = input(['Ligne début (1-', num2str(hauteur), ') [Défaut 50]: ']);
if isempty(ligne_debut), ligne_debut = 50; end
col_debut = input(['Colonne début (1-', num2str(largeur), ') [Défaut 100]: ']);
if isempty(col_debut), col_debut = 100; end
% On prend une taille fixe ou on peut ajouter des inputs pour fin
ligne_fin = min(hauteur, ligne_debut + 100);
col_fin = min(largeur, col_debut + 100);
bloc = img_gray(ligne_debut:ligne_fin, col_debut:col_fin);

% 4. Histogramme et Recherche de niveau
occurrence = imhist(img_gray);
niveau_rech = input('Entrez le niveau de gris à chercher (0-255) : ');
disp(['Nombre de pixels de niveau ', num2str(niveau_rech), ' : ', num2str(occurrence(niveau_rech + 1))]);

% 5. Profils d'intensité
ligne_p = round(hauteur/2);
profil_ligne = double(img_gray(ligne_p, :));
colonne_p = round(largeur/2);
profil_colonne = double(img_gray(:, colonne_p));

% 6. Bruits
densite = input('Entrer la densité du bruit (ex: 0.05) : ');
img_sp = imnoise(img_gray, 'salt & pepper', densite);
img_speckle = imnoise(img_gray, 'speckle', densite);
img_gauss = imnoise(img_gray, 'gaussian', 0, 0.01);

% 7. Filtres
disp('Choisissez un filtre à appliquer : 1-Sobel, 2-Roberts, 3-Laplacien');
filtre_choisi = input('Entrez le numéro : ');

switch filtre_choisi
    case 1
        img_filtre = edge(img_gray, 'sobel');
        filtre_nom = 'Sobel';
    case 2
        img_filtre = edge(img_gray, 'roberts');
        filtre_nom = 'Roberts';
    case 3
        img_filtre = edge(img_gray, 'log');
        filtre_nom = 'Laplacien';
    otherwise
        img_filtre = edge(img_gray, 'sobel');
        filtre_nom = 'Sobel';
end

% 8. Calcul SNR / PSNR
img_gray_d = double(img_gray);
img_filtre_d = double(img_filtre) * 255; % Scale pour comparaison
mse = mean((img_gray_d(:) - img_filtre_d(:)).^2);
if mse > 0
    psnr_val = 10 * log10(255^2 / mse);
else
    psnr_val = Inf;
end
disp(['PSNR ', filtre_nom, ' : ', num2str(psnr_val), ' dB']);

% 9. Affichage Final (Subplots)
figure('Name', 'Traitement Image Complet', 'Position', [50 50 1200 800]);

subplot(3,4,1); imshow(img_gray); title('Originale');
subplot(3,4,2); imshow(img_rot_f); title('Rotation 90°');
subplot(3,4,3); imshow(img_rot_v); title(['Rotation ', num2str(angle), '°']);
subplot(3,4,4); imshow(img_inv); title('Inversion');

subplot(3,4,5); imshow(bloc); title('Bloc extrait');
subplot(3,4,6); imhist(img_gray); title('Histogramme');
subplot(3,4,7); plot(profil_ligne); title('Profil Ligne');
subplot(3,4,8); plot(profil_colonne); title('Profil Colonne');

subplot(3,4,9); imshow(img_sp); title('Bruit S&P');
subplot(3,4,10); imshow(img_gauss); title('Bruit Gaussien');
subplot(3,4,11); imshow(img_filtre); title(['Filtre ', filtre_nom]);
subplot(3,4,12); text(0.1, 0.5, ['PSNR: ', num2str(psnr_val, '%.2f'), ' dB']); axis off;