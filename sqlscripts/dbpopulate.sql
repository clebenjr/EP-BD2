-- Define o schema a ser utilizado
SET search_path TO ep2_bd2;

-- Povoando a tabela pais
INSERT INTO pais (nome) VALUES
('Brasil'), ('Angola'), ('Portugal'), ('Moçambique'), ('Cabo Verde'),
('Guiné-Bissau'), ('São Tomé e Príncipe'), ('Timor-Leste'), ('Ucrânia'), ('Rússia'),
('Sudão'), ('Colômbia'), ('Afeganistão'), ('Síria'), ('Iêmen'),
('Myanmar'), ('Etiópia'), ('Nigéria'), ('Somália'), ('Palestina'),
('Estados Unidos'), ('Canadá'), ('México'), ('Reino Unido'), ('França'),
('Alemanha'), ('Polônia'), ('Sérvia'), ('China'), ('Índia'),
('Geórgia'), ('Armênia'), ('Japão'), ('República de Azânia'), ('Bielorrússia'), ('Noruega');

-- Povoando a tabela conflito
-- IDs de 1 a 25
INSERT INTO conflito (numero_de_mortos, numero_de_feridos, nome) VALUES
(150000, 300000, 'Guerra Civil da Nortúmbria'),
(75000, 150000, 'Conflito da Fronteira Escarlate'),
(30000, 60000, 'Insurreição do Vale Perdido'),
(120000, 240000, 'Guerra dos Balcãs Ocidentais'), 
(5000, 10000, 'Revolta dos Camponeses do Sul'),
(250000, 500000, 'Grande Guerra Continental Africana'),
(10000, 20000, 'Disputa das Ilhas Nebulosas do Atlântico'),
(45000, 90000, 'Cerco da Cidade Dourada'),
(8000, 16000, 'Levante dos Mineiros de Kessel'),
(60000, 120000, 'Guerra da Água Azul Profundo'),
(90000, 180000, 'Conflito da Floresta Sombria Eterna'),
(20000, 40000, 'Batalha dos Montes Gelados do Norte'),
(50000, 100000, 'Insurreição Popular do Leste Unido'),
(100000, 200000, 'Crise dos Refugiados da Fronteira Setentrional'), 
(15000, 30000, 'Rebelião dos Mercadores da Costa'),
(200000, 400000, 'Guerra da Secessão Ocidental Prolongada'),
(35000, 70000, 'Disputa Territorial do Rio Bravo Seco'),
(65000, 130000, 'Cerco da Fortaleza Ancestral Esquecida'),
(95000, 190000, 'Levante dos Clãs Unidos da Montanha'),
(40000, 80000, 'Guerra Santa da Montanha Sagrada Iluminada'),
(55000, 110000, 'Conflito Transfronteiriço do Cáucaso'), 
(85000, 170000, 'Guerra Comercial do Pacífico'), 
(25000, 50000, 'Intervenção na República de Azânia'), 
(15000, 35000, 'Crise de Estabilidade em Volhynia'), 
(45000, 95000, 'Disputa de Recursos no Ártico'); 

-- Povoando a tabela afeta
INSERT INTO afeta (nome_pais, id_conflito) VALUES
('Ucrânia', 1), ('Rússia', 1), ('Palestina', 1), 
('Sudão', 2), ('Etiópia', 2),
('Colômbia', 3), ('Brasil', 3), ('Sérvia', 4), ('Portugal', 4), ('Polônia', 4),
('Afeganistão', 5), ('Myanmar', 5), ('Nigéria', 6), ('Somália', 6),
('Portugal', 7), ('Cabo Verde', 7), ('Angola', 8), ('Moçambique', 8),
('Brasil', 9), ('Colômbia', 9), ('Timor-Leste', 10), ('Guiné-Bissau', 10),
('Palestina', 11), ('Síria', 11), ('Rússia', 12), ('Ucrânia', 12),
('Etiópia', 13), ('Sudão', 13),
('Myanmar', 14), ('Afeganistão', 14), ('Estados Unidos', 14), ('Canadá', 14), ('México', 14),
('Iêmen', 15), ('Somália', 15), ('Nigéria', 16), ('Cabo Verde', 16),
('São Tomé e Príncipe', 17), ('Guiné-Bissau', 17), ('Angola', 18), ('Brasil', 18),
('Angola', 19), ('Moçambique', 19), ('Palestina', 20), ('Síria', 20),
('Rússia', 21), ('Geórgia', 21), ('Armênia', 21),
('Estados Unidos', 22), ('China', 22), ('Japão', 22),
('Estados Unidos', 23), ('França', 23), ('República de Azânia', 23),
('Polônia', 24), ('Ucrânia', 24), ('Bielorrússia', 24),
('Rússia', 25), ('Canadá', 25), ('Estados Unidos', 25), ('Noruega', 25);

-- Povoando tabelas de causas de conflitos (GARANTINDO PELO MENOS UMA CAUSA POR CONFLITO)
INSERT INTO regioes_conflito (id_conflito, regiao) VALUES
(1, 'Norte da Ucrânia'), (1, 'Oeste da Rússia'), 
(4, 'Kosovo'), (4, 'Bósnia'),                 
(7, 'Ilhas Selvagens'),                        
(12, 'Donbass'),                               
(17, 'Margem do Rio Apa'),                     
(21, 'Ossétia do Sul'),                        
(24, 'Lviv Oblast');                           

INSERT INTO materias_primas_conflito (id_conflito, materia_prima) VALUES 
(2, 'Petróleo'), (2, 'Água'),                 
(3, 'Ouro'), (3, 'Esmeraldas'),               
(6, 'Petróleo'), (6, 'Gás Natural'),          
(9, 'Coltan'),                                
(10, 'Fosfato'),                               
(15, 'Controle de Rotas Marítimas'),          
(22, 'Semicondutores'), (22, 'Terras Raras'), 
(25, 'Gás Natural Ártico');                   

INSERT INTO religioes_conflito (id_conflito, religiao) VALUES
(1, 'Disputa de Locais Sagrados Antigos'), 
(4, 'Cristianismo Ortodoxo Sérvio'), (4, 'Islamismo Bósnio'), 
(8, 'Culto do Sol Dourado'), (8, 'Fé da Lua Prateada'), 
(11, 'Judaísmo'), (11, 'Islamismo'),          
(16, 'Separatismo Religioso Ocidental'),      
(20, 'Fé Ancestral da Montanha');             

INSERT INTO etnias_conflito (id_conflito, etnia) VALUES
(5, 'Pashtun'), (5, 'Hazara'),                 
(13, 'Oromo'), (13, 'Amhara'),                 
(14, 'Anglo-Descendentes (Exemplo)'), (14, 'Latino-Americanos (Exemplo)'), 
(18, 'Clã da Pedra'), (18, 'Povo do Rio'),    
(19, 'Bakongo'), (19, 'Luba'),                 
(23, 'Azanianos Nativos'), (23, 'Colonizadores (Exemplo)'); 


-- Povoando a tabela grupo_armado com total_baixas calculado
INSERT INTO grupo_armado (nome, total_baixas) VALUES
('Exército de Libertação Nacional', 450),      
('Forças Rebeldes Unidas', 500),               
('Milícia Popular do Sul', 100),                
('Guardiões da Fronteira Norte', 400),         
('Legião Estrangeira Vermelha', 800),          
('Brigada Fantasma', 50),                       
('Comandos do Deserto', 200),                   
('Divisão Sombra', 350),                       
('Frente Patriótica Revolucionária', 250),     
('Movimento pela Autodeterminação Popular', 600),
('Resistência Armada do Povo', 700),            
('União dos Combatentes Livres', 180),         
('Força de Defesa Territorial Unificada', 450), 
('Grupo de Intervenção Rápida Alfa', 320),    
('Aliança Rebelde do Leste Profundo', 550),   
('Combatentes pela Justiça Social Agora', 120),
('Exército Secreto do Povo Soberano', 420),    
('Guerrilha da Montanha Negra Indomável', 90),
('Legião dos Oprimidos em Luta', 280),        
('Vanguarda da Libertação Continental', 0),   
('Brigada Europeia de Defesa', 1200),          
('Força Tarefa Americana', 1500),             
('Dragões Asiáticos', 900),                   
('Lobos do Ártico', 400),                     
('Milícia da Fronteira Mexicana', 250);        

-- Povoando a tabela divisao (IDs sequenciais DENTRO de cada grupo)
INSERT INTO divisao (id, id_grupo, barcos, homens, tanques, avioes, baixas) VALUES
(1, 1, 5, 2000, 50, 5, 300),    -- Grupo 1, Divisão 1
(2, 1, 0, 1500, 30, 2, 150),    -- Grupo 1, Divisão 2
(1, 2, 10, 3000, 70, 10, 500),   -- Grupo 2, Divisão 1
(1, 3, 2, 1000, 20, 0, 100),    -- Grupo 3, Divisão 1
(1, 4, 0, 2500, 60, 8, 400),    -- Grupo 4, Divisão 1
(1, 5, 15, 5000, 100, 15, 800),   -- Grupo 5, Divisão 1
(1, 6, 1, 800, 10, 1, 50),     -- Grupo 6, Divisão 1
(1, 7, 0, 1200, 25, 3, 200),    -- Grupo 7, Divisão 1
(1, 8, 8, 2200, 45, 7, 350),    -- Grupo 8, Divisão 1
(1, 9, 3, 1800, 35, 4, 250),    -- Grupo 9, Divisão 1
(1, 10, 0, 3500, 80, 12, 600),   -- Grupo 10, Divisão 1
(1, 11, 20, 4000, 90, 20, 700),   -- Grupo 11, Divisão 1
(1, 12, 4, 1600, 28, 6, 180),   -- Grupo 12, Divisão 1
(1, 13, 0, 2800, 55, 9, 450),   -- Grupo 13, Divisão 1
(1, 14, 6, 2000, 40, 5, 320),   -- Grupo 14, Divisão 1
(1, 15, 12, 3200, 75, 11, 550),  -- Grupo 15, Divisão 1
(1, 16, 0, 1300, 15, 0, 120),   -- Grupo 16, Divisão 1
(1, 17, 7, 2700, 58, 8, 420),   -- Grupo 17, Divisão 1
(1, 18, 2, 900, 18, 2, 90),    -- Grupo 18, Divisão 1
(1, 19, 5, 1700, 33, 3, 280),   -- Grupo 19, Divisão 1
-- Grupo 20 não tem divisões neste script
(1, 21, 30, 10000, 200, 50, 1200), -- Grupo 21, Divisão 1
(1, 22, 50, 15000, 300, 70, 1500), -- Grupo 22, Divisão 1
(1, 23, 10, 8000, 150, 30, 900),  -- Grupo 23, Divisão 1
(1, 24, 5, 3000, 80, 10, 400),   -- Grupo 24, Divisão 1
(1, 25, 0, 2000, 40, 0, 250);    -- Grupo 25, Divisão 1

-- Povoando a tabela lider_politico
INSERT INTO lider_politico (nome, id_grupo, descricao_apoio) VALUES
('Alistair Vance', 1, 'Apoio popular e veteranos de guerra'), ('Sofia Rostova', 2, 'Apoio de dissidentes e intelectuais'),
('Kaelen', 3, 'Apoio de milícias locais e agricultores'), ('Lyra Moon', 4, 'Apoio de comerciantes e guardas fronteiriços'),
('Ivan Petrov', 5, 'Apoio de mercenários e exilados'), ('Anya Sharma', 6, 'Apoio de espiões e unidades de elite'),
('Omar Al-Jamil', 7, 'Apoio de tribos do deserto e nômades'), ('Rex Nebula', 8, 'Apoio de unidades de reconhecimento'),
('Elena Petrova', 9, 'Apoio de nacionalistas e industriais'), ('Kai Manu', 10, 'Apoio de minorias étnicas e ativistas'),
('Jian Li', 11, 'Apoio de estudantes e trabalhadores urbanos'), ('Marcus Tiberius', 12, 'Apoio de legiões leais'),
('Aisha Bello', 13, 'Apoio de comunidades rurais e defensores'), ('Zara Khan', 14, 'Apoio de forças especiais e tecnocratas'),
('Viktor Orlov', 15, 'Apoio de aristocratas e senhores feudais'), ('Miguel Silva', 16, 'Apoio de comunidades religiosas'),
('"Sombra"', 17, 'Apoio de redes clandestinas e informantes'), ('Urso Cinzento', 18, 'Apoio de tribos montanhesas'),
('Nzinga II', 19, 'Apoio de matriarcas e guerreiras'), ('O Oráculo', 20, 'Apoio de visionários e místicos'),
('Jean-Luc Picard', 21, 'Conselho da Federação Europeia'), ('James Kirk', 22, 'Congresso dos Estados Unidos'),
('Li Shang', 23, 'Comitê Central Asiático'), ('Sven Olafson', 24, 'Parlamento Nórdico Unificado'), ('Maria Sanchez', 25, 'Assembleia da Fronteira');

-- Povoando a tabela chefe_militar (referenciando os novos IDs de divisão)
INSERT INTO chefe_militar (id, faixa_hierarquica, nome_lider_politico, id_grupo_lider_politico, id_divisao, id_grupo_armado_divisao) VALUES
(DEFAULT, 'General de Brigada', 'Alistair Vance', 1, 1, 1),      -- Comanda Divisão 1 do Grupo 1
(DEFAULT, 'Coronel', 'Sofia Rostova', 2, 1, 2),                -- Comanda Divisão 1 do Grupo 2
(DEFAULT, 'Major-General', 'Kaelen', 3, 1, 3),                  -- Comanda Divisão 1 do Grupo 3
(DEFAULT, 'Capitão', 'Lyra Moon', 4, 1, 4),                      -- Comanda Divisão 1 do Grupo 4
(DEFAULT, 'Tenente-Coronel', 'Ivan Petrov', 5, 1, 5),            -- Comanda Divisão 1 do Grupo 5
(DEFAULT, 'General de Divisão', 'Anya Sharma', 6, 1, 6),          -- Comanda Divisão 1 do Grupo 6
(DEFAULT, 'Sargento-Mor', 'Omar Al-Jamil', 7, 1, 7),             -- Comanda Divisão 1 do Grupo 7
(DEFAULT, 'Major', 'Rex Nebula', 8, 1, 8),                      -- Comanda Divisão 1 do Grupo 8
(DEFAULT, 'Coronel Pleno', 'Elena Petrova', 9, 1, 9),            -- Comanda Divisão 1 do Grupo 9
(DEFAULT, 'General', 'Kai Manu', 10, 1, 10),                     -- Comanda Divisão 1 do Grupo 10
(DEFAULT, 'Comandante', 'Jian Li', 11, 1, 11),                   -- Comanda Divisão 1 do Grupo 11
(DEFAULT, 'Almirante', 'Marcus Tiberius', 12, 1, 12),             -- Comanda Divisão 1 do Grupo 12
(DEFAULT, 'Tenente', 'Aisha Bello', 13, 1, 13),                   -- Comanda Divisão 1 do Grupo 13
(DEFAULT, 'Brigadeiro', 'Zara Khan', 14, 1, 14),                 -- Comanda Divisão 1 do Grupo 14
(DEFAULT, 'Capitão de Fragata', 'Viktor Orlov', 15, 1, 15),       -- Comanda Divisão 1 do Grupo 15
(DEFAULT, 'Marechal de Campo', 'Miguel Silva', 16, 1, 16),        -- Comanda Divisão 1 do Grupo 16
(DEFAULT, 'Cabo Mestre', '"Sombra"', 17, 1, 17),                  -- Comanda Divisão 1 do Grupo 17
(DEFAULT, 'General de Exército', 'Urso Cinzento', 18, 1, 18),     -- Comanda Divisão 1 do Grupo 18
(DEFAULT, 'Aspirante-a-Oficial', 'Nzinga II', 19, 1, 19),         -- Comanda Divisão 1 do Grupo 19
(DEFAULT, 'Comodoro', 'O Oráculo', 20, 1, 19),                   -- Chefe do Oráculo (Grupo 20) comanda Divisão 1 do Grupo 19
(DEFAULT, 'Marechal Europeu', 'Jean-Luc Picard', 21, 1, 21),     -- Comanda Divisão 1 do Grupo 21
(DEFAULT, 'General 5 Estrelas', 'James Kirk', 22, 1, 22),       -- Comanda Divisão 1 do Grupo 22
(DEFAULT, 'Grande Estrategista', 'Li Shang', 23, 1, 23),          -- Comanda Divisão 1 do Grupo 23
(DEFAULT, 'Comandante Nórdico', 'Sven Olafson', 24, 1, 24),       -- Comanda Divisão 1 do Grupo 24
(DEFAULT, 'Jefe de Plaza', 'Maria Sanchez', 25, 1, 25);          -- Comanda Divisão 1 do Grupo 25

-- Povoando a tabela participa_grupo
INSERT INTO participa_grupo (id_conflito, id_grupo, data_de_incorporacao, data_de_saida) VALUES
(1, 1, '2022-02-24', NULL), (1, 2, '2022-03-01', NULL), (1, 5, '2022-04-10', '2023-01-20'),
(4, 21, '2023-01-01', NULL), (4, 5, '2023-02-01', NULL),
(14, 4, '2024-01-01', NULL), (14, 22, '2024-01-05', NULL), (14, 25, '2024-01-10', NULL),
(22, 22, '2025-01-01', NULL), (22, 23, '2025-01-01', NULL),
(23, 22, '2024-06-01', NULL), (23, 21, '2024-06-05', NULL),
(25, 22, '2026-01-01', NULL), (25, 24, '2026-01-01', NULL), (25, 1, '2026-02-01', NULL);

-- Povoando a tabela arma
INSERT INTO arma (tipo, capacidade_destrutiva) VALUES
('Fuzil de Assalto AKM', 7), ('Pistola Makarov PM', 4), ('Granada F1', 7),
('Morteiro 2B14 Podnos', 9), ('RPG-7', 8), ('Metralhadora PKM', 8),
('Mina Antipessoal PMN-2', 7), ('Faca de Combate NR-40', 3), ('Bomba Improvisada (IED)', 9),
('Rifle de Precisão SVD Dragunov', 8), ('Submetralhadora PPSh-41', 6), ('Canhão Antiaéreo ZU-23-2', 9),
('Míssil Antitanque 9M133 Kornet', 9), ('Drone de Ataque Shahed-136', 8), ('Gás Lacrimogêneo K-51', 2),
('C4 Explosivo Plástico', 9), ('Coquetel Molotov', 5), ('Espingarda Saiga-12', 7),
('Lança-Granadas AGS-17', 9), ('Míssil Terra-Ar S-300', 10),
('Barret M82', 8), ('M200 Intervention', 8), ('Fuzil M16', 7), ('Caça F-35', 10), ('Tanque M1 Abrams', 9);

-- Povoando a tabela traficante
INSERT INTO traficante (nome) VALUES
('Viktor Bout'), ('Monzer al-Kassar'), ('Adnan Khashoggi'), ('Semyon Mogilevich'),
('Rafael Caro Quintero'), ('Joaquín "El Chapo" Guzmán'), ('Khun Sa'), ('Pablo Escobar'),
('Griselda Blanco'), ('Ismael "El Mayo" Zambada'), ('Carlos Lehder'), ('George Jung'),
('Frank Lucas'), ('Nicky Barnes'), ('Artur "O Rei" Almeida'), ('Fernanda "A Dama de Ferro" Costa'),
('Ricardo "O Fantasma" Silva'), ('Beatriz "A Viúva Negra" Oliveira'), ('Tiago "O Negociador" Pereira'), ('Sofia "A Serpente" Lima'),
('John Doe Arms LLC'), ('EuroArms Corp');

-- Povoando a tabela possui_arma_traficante
INSERT INTO possui_arma_traficante (tipo_arma, nome_traficante, quantidade_disponivel) VALUES
('Fuzil de Assalto AKM', 'Viktor Bout', 5000), ('Pistola Makarov PM', 'Monzer al-Kassar', 2000),
('Granada F1', 'Adnan Khashoggi', 10000), ('Barret M82', 'Viktor Bout', 150),
('Fuzil M16', 'John Doe Arms LLC', 10000), ('Caça F-35', 'John Doe Arms LLC', 50),
('Tanque M1 Abrams', 'EuroArms Corp', 200), ('Míssil Antitanque 9M133 Kornet', 'EuroArms Corp', 500),
('M200 Intervention', 'Monzer al-Kassar', 100), 
('Barret M82', 'Artur "O Rei" Almeida', 50), 
('M200 Intervention', 'Sofia "A Serpente" Lima', 30);


-- Povoando a tabela fornece_arma_grupo (Total acumulado, quantidade > 0)
INSERT INTO fornece_arma_grupo (id_grupo_armado, tipo_arma, nome_traficante, quantidade_fornecida) VALUES
(1, 'Fuzil de Assalto AKM', 'Viktor Bout', 1500), 
(2, 'Pistola Makarov PM', 'Monzer al-Kassar', 500),
(22, 'Fuzil M16', 'John Doe Arms LLC', 5000), 
(22, 'Tanque M1 Abrams', 'John Doe Arms LLC', 50),
(21, 'Míssil Antitanque 9M133 Kornet', 'EuroArms Corp', 100),
(1, 'Barret M82', 'Viktor Bout', 20),             
(10, 'Barret M82', 'Artur "O Rei" Almeida', 10),  
(2, 'Barret M82', 'Adnan Khashoggi', 25),         
(5, 'M200 Intervention', 'Monzer al-Kassar', 15),  
(15, 'M200 Intervention', 'Sofia "A Serpente" Lima', 5), 
(7, 'M200 Intervention', 'Semyon Mogilevich', 12);


-- Povoando a tabela organizacao_mediadora
INSERT INTO organizacao_mediadora (id, nome, tipo) VALUES
(DEFAULT, 'Organização das Nações Unidas (ONU)', 'Internacional'),
(DEFAULT, 'Comitê Internacional da Cruz Vermelha (CICV)', 'Internacional'),
(DEFAULT, 'Médicos Sem Fronteiras (MSF)', 'Não Governamental'),
(DEFAULT, 'Anistia Internacional', 'Não Governamental'),
(DEFAULT, 'Human Rights Watch (HRW)', 'Não Governamental'),
(DEFAULT, 'União Africana (UA)', 'Internacional'),
(DEFAULT, 'Liga dos Estados Árabes', 'Internacional'),
(DEFAULT, 'Organização para a Segurança e Cooperação na Europa (OSCE)', 'Internacional'),
(DEFAULT, 'Centro Carter', 'Não Governamental'),
(DEFAULT, 'Comunidade de Sant''Egídio', 'Não Governamental'),
(DEFAULT, 'Agência dos EUA para o Desenvolvimento Internacional (USAID)', 'Governamental'),
(DEFAULT, 'Ministério das Relações Exteriores da Noruega', 'Governamental'),
(DEFAULT, 'Ministério das Relações Exteriores da Alemanha', 'Governamental'),
(DEFAULT, 'OTAN (Organização do Tratado do Atlântico Norte)', 'Internacional'),
(DEFAULT, 'Departamento de Estado dos EUA', 'Governamental'),
(DEFAULT, 'Alto Comissariado das Nações Unidas para os Refugiados (ACNUR)', 'Internacional');

-- Povoando a tabela depende_organizacao
INSERT INTO depende_organizacao (id_organizacao_mediada, id_organizacao_mediadora) VALUES
(6, 1), (7, 1), (2,1), (3,2), (4,1), (16,1), 
(8, 14), (11, 15), (12, 8);

-- Povoando a tabela participa_organizacao
INSERT INTO participa_organizacao (id_conflito, id_organizacao, data_incorporacao, data_saida, tipo_ajuda, numero_pessoas) VALUES
(1, 1, '2022-03-01', NULL, 'Diplomática', 50), (1, 2, '2022-02-28', NULL, 'Médica', 200),
(4, 8, '2023-01-15', NULL, 'Diplomática', 40), (4, 14, '2023-02-01', NULL, 'Presencial', 100),
(14, 1, '2024-01-20', NULL, 'Diplomática', 60), (14, 11, '2024-02-01', NULL, 'Médica', 250),
(22, 1, '2025-01-10', NULL, 'Diplomática', 30),
(23, 15, '2024-06-10', NULL, 'Diplomática', 20), (23, 1, '2024-06-15', NULL, 'Presencial', 15);

-- Povoando a tabela dialoga
INSERT INTO dialoga (id_organizacao, nome_lider_politico, id_grupo_lider_politico) VALUES
(1, 'Alistair Vance', 1), (2, 'Sofia Rostova', 2),
(8, 'Jean-Luc Picard', 21), (14, 'James Kirk', 22),
(1, 'Li Shang', 23), (15, 'James Kirk', 22);

