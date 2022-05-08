

`define maze_width 6

module maze(
	input clk,
	input [`maze_width-1:0] starting_col, starting_row,
	input maze_in,
	output reg [`maze_width-1:0] row, col,
	output reg	maze_oe,
	output reg	maze_we,
	output reg	done);


reg [5:0] last_row, last_col;  //copiile coordonatelor, folosite pentru a retine starea anterioara

parameter S0 = 0;
parameter S1 = 1;
parameter S2 = 2; 
parameter S3 = 3;
parameter S4 = 4;
parameter S5 = 5;
parameter S6 = 6;
parameter S7 = 7;
parameter east = 9;
parameter west = 10;
parameter north = 11;
parameter south = 12;
parameter final_labirint = 8;

`define est 0
`define vest 1
`define sud 2
`define nord 3

reg [1:0] pct_cardinal; // alegem de la 0 la 3 punctele cardinale
reg [3:0] state, next_state;

always @(posedge clk) begin
		state<=next_state;
end

always @(*) begin
	 done=0;
	 maze_we=0;
	 maze_oe=0;
	 next_state=S0;
	 
	 
case(state)
	 
	S0: begin
			
		maze_we = 1; // programul va pune valoarea 2 pe pozitia anterioara pentru a-si da seama ca a trecut prin acel loc
		// conform algoritmului wall follower (right hand rule) ne vom ghida tot timpul dupa peretele din dreapta
		pct_cardinal = `est;	
		col = starting_col;
		row = starting_row;			
		last_col = starting_col;
		last_row = starting_row;

	next_state=S1;
	
	end

	S1 : begin // aflam unde ne putem deplasa din pozitia initiala
			if(pct_cardinal==`est) begin
					 col=col+1;
			end
					  
			else if(pct_cardinal==`vest) begin
					 col=col-1;
		   end
					  
			else if(pct_cardinal==`sud) begin
						row=row+1;
			end
					  
			else if(pct_cardinal==`nord) begin
					 row=row-1;
			end	 
					  
	maze_oe=1;		
	next_state=S2;
				
	end

	S2: begin
			
		if(maze_in == 0) begin
			last_row=row;
			last_col=col;
					
	maze_we=1;
	next_state=S3;
	
	end

		else begin //ma reintorc in S1;
				
			col=last_col;
			row=last_row;
			pct_cardinal=pct_cardinal+1;
					
			next_state=S1;

		end

	end

	S3: begin //probam in ce punct cardinal ne vom indrepta
	
		if(pct_cardinal==`est) begin
				last_row=row;
				row=row+1; //verificam daca e posibila deplasarea in sud
		end
		if(pct_cardinal==`vest) begin
				last_row=row;
				row=row-1; //verificam daca e posibila deplasarea in nord
		end
		if(pct_cardinal==`sud) begin
				last_col=col;
				col=col-1; //verificam daca e posibila deplasarea in vest
		end
		if(pct_cardinal==`nord) begin
				last_col=col;
				col=col+1; // verificam daca e posibila deplasarea in est
		end
						
	maze_oe=1;
	next_state=S4;

	end
			
	S4: begin
			
		if(pct_cardinal==`est) begin
				next_state=east;
		end
					
		else if (pct_cardinal==`vest) begin
				next_state=west;
		end
					
		else if(pct_cardinal==`sud) begin
				next_state=south;
		end
					
		else if(pct_cardinal==`nord) begin			
				next_state=north;
		end
					
	end
			
			
	east: begin
			// pastrez pozitia anterioara si ma reintorc de unde am plecat si merg spre est
		if(maze_in==1) begin 
			last_col=col; 
			row=last_row; 
			col=col+1; 
		end
			
		else begin 
					//salvam coordonatele si ne deplasam spre sud
			pct_cardinal=`sud;
			last_col=col;
			last_row=row;

		end	
		
	maze_oe=1;
	next_state=S5;
			
	end
			
			
	west: begin
			// pastrez pozitia anterioara si ma reintorc de unde am plecat si merg spre vest
		if(maze_in==1) begin 
			last_col=col; 
			row=last_row; 
			col=col-1; 
		end
			
		else begin
			//salvam coordonatele si ne deplasam spre nord
			pct_cardinal=`nord;
			last_row=row;
			last_col=col;
		end
		
	maze_oe=1;
	next_state=S5;
	
	end
			
			
	north: begin
			// pastrez pozitia anterioara si ma reintorc de unde am plecat si merg spre nord
		if(maze_in==1) begin 
			last_row=row;
			col=last_col;
			row=row-1;
		end
			
		else begin //salvam coordonatele si ne deplasam spre est
			pct_cardinal=`est;
			last_row=row;
			last_col=col;
		end
		
	maze_oe=1;
	next_state=S5;
				
	end
			
			
	south: begin
			 // pastrez pozitia anterioara si ma reintorc de unde am plecat si merg spre sud
		if(maze_in==1) begin
			last_row=row;
			col=last_col;
			row=row+1;
		end

		else begin //salvam coordonatele si ne deplasam spre vest
			pct_cardinal=`vest;
			last_row=row;
			last_col=col;
		end
			
	maze_oe=1;
	next_state=S5;
			
	end

	S5: begin

		if(maze_in==0)  begin // daca e cale libera de trecere
			if(col==0 || row==0 || row==63 || col==63) begin // daca suntem la marginile labirintului
				maze_we=1;
				next_state=final_labirint;

			end

			else begin // daca e perete
				next_state=S7;
			end
		end

		else begin //ma reintorc
			next_state=S6; 
		end

	end
			
	S6: begin // **
			
		col=last_col;
		row=last_row;
		//ne deplasam in alta pozitie, avand in vedere ca am intalnit un obstacol
		
		if(pct_cardinal==`est) begin
			pct_cardinal=`vest;
		end
		
		else if(pct_cardinal==`vest) begin
			pct_cardinal=`est;
		end
		
		else if(pct_cardinal==`sud) begin
			pct_cardinal=`nord;
		end
		
		else if(pct_cardinal==`nord) begin
			pct_cardinal=`sud;
		end

	next_state=S3;
			
	end
			
	S7: begin // ***
			
		last_row=row;
		last_col=col;
		maze_we=1;
		next_state = S3;
			
	end
						
	final_labirint: begin // starea marcata a automatului, unde vom spune ca am gasit iesirea din labirint, done devine 1.
	
		done=1; 
		
	end

	endcase

end

endmodule
