SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[Rsp_Grava_Transacao]
	@txt_registro	varchar(255)

 AS
SET NOCOUNT ON
declare	@cod_retorno 	int,
	@tipo_reg	char(1)

BEGIN 
begin transaction  
	insert into log_trans (data_hora, num_caixa, cod_cliente, txt_registro, dat_incl)
	values(	
	substring(@txt_registro,4,16) ,
	substring(@txt_registro,1,3), 
 	substring(@txt_registro,21,11),
 	substring(@txt_registro,1,255),
	getdate()   )

	select @cod_retorno = @@error

	if @cod_retorno <> 0 
	begin
		if @cod_retorno = 2627 
		begin
			rollback transaction
			return(0)
		end
		else
		begin
			rollback transaction
			insert into log_erro (data_hora, num_caixa, cod_cliente, txt_registro, dat_ocor, cod_erro)
			values(	
				substring(@txt_registro,4,16) ,
				substring(@txt_registro,1,3) , 
				substring(@txt_registro,21,11) ,
			 	substring(@txt_registro,1,255) ,
				getdate() ,
				@cod_retorno   )
			raiserror('Erro inclusao log_trans. Cod = %d',14,1,@cod_retorno)
			return(8)
		end
	end
	else
	begin
		select @tipo_reg = substring(@txt_registro,20,1)
		insert into ind_trans (data_hora, num_caixa, cod_cliente, ind_prior, data_hora_envio)
		values(	
			substring(@txt_registro,4,16), 
			substring(@txt_registro,1,3),
 			substring(@txt_registro,21,11),
			case @tipo_reg
				when 'F' then 1		-- atualizacao protocolo - desbloqueio cartao
				when 'A' then 5		-- consulta venda
				when 'C' then 10	-- formalizacao produto financ
				when 'I' then 15	-- consulta auto-atendimento
				when 'J' then 20	-- consulta cartao presente
				when 'L' then 25	-- autorizacao cartao presente
				when 'O' then 30	-- consulta cartao presente (internet)
				when 'P' then 35	-- consulta protocolo
				when 'Q' then 40	-- consulta emprestimo pessoal
				when 'R' then 45	-- atualizacao recebto emprest pessoal
				when 'X' then 50	-- atualizacao telefone
				when 'D' then 55	-- atualização receb dados para pagto
				when 'E' then 60	-- atualizacao receb por extrato
				when 'B' then 65	-- venda
				when '9' then 68	-- atualizacao recebto cheque devolvido
				when 'N' then 70	-- atualizacao cartao presente		
				when 'H' then 75	-- atualizacao novacao de divida
				when 'K' then 80	-- estorno recebimento

				else 99
			end,
			getdate()
			)

		select @cod_retorno = @@error
	
		if @cod_retorno <> 0
		begin
			if @cod_retorno = 2627 
			begin
				rollback transaction
				return(0)
			end
			else
			begin
				rollback transaction
				insert into log_erro (data_hora, num_caixa, cod_cliente, txt_registro, dat_ocor, cod_erro)
				values(	
					substring(@txt_registro,4,16) ,
					substring(@txt_registro,1,3) , 
					substring(@txt_registro,21,11) ,
				 	substring(@txt_registro,1,255) ,
					getdate() ,
					@cod_retorno   )
				raiserror('Erro inclusao ind_trans. Cod = %d',14,1,@cod_retorno)
				return(8)
			end
		end
		else
		begin
			commit transaction
			return(0)
		end
	end
END
GO
