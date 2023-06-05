`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//
// Branch predictor module.
//
//
//////////////////////////////////////////////////////////////////////////////////

`define     BRANCH_ADDRESS      2
`define     BRANCH_OPCODE       7'b1100011
`define     TABLE_ADR_WIDTH     6
`define     TABLE_SIZE          2**`TABLE_ADR_WIDTH
`define     TABLE_WIDTH         32

module Branch_Predictor(
    input           clk,        // Clock source.
    input           data_valid, // Indicates received data is valid.
    input   [2:0]   pcSource,   // Target address select signal for the PC.
    input   [6:0]   opcode,     // Opcode (lowest 7 bits) of currently executing instruction.
    input   [31:0]  pc          // Program Counter (PC) value.
    );



// Evaluate if branch is taken or not.
logic Branch_Taken;
logic Branch_Not_Taken;
always_comb
begin
    if( (data_valid == 1) && (opcode == `BRANCH_OPCODE) && (pcSource == `BRANCH_ADDRESS) )
        Branch_Taken = 1;
    else
        Branch_Taken = 0;
    
    if( (data_valid == 1) && (opcode == `BRANCH_OPCODE) && (pcSource != `BRANCH_ADDRESS) )
        Branch_Not_Taken = 1;
    else
        Branch_Not_Taken = 0;
end



// Evaluate if current instruction is a branch instruction.
logic Is_Branch_Instruction;
always_comb
begin
    if( (data_valid == 1) && (opcode == `BRANCH_OPCODE) )
        Is_Branch_Instruction = 1;
    else
        Is_Branch_Instruction = 0;
end



// Begin Branch Instruction Counter.
// A new instruction is fetched when data_valid is set high.
logic [31:0] Total_Branch_Instructions = 0;

always_ff @ (posedge clk)
begin
    if( Is_Branch_Instruction )
        Total_Branch_Instructions++;
end
// End Branch Instruction Counter.



// Begin Static Branch Predictor.
// This implementation always predicts that the branch will be taken.
logic [31:0] Total_Correct_Predictions_SBP = 0;

// Update prediction counter.
always_ff @ (posedge clk)
begin
    if( Branch_Taken )
        Total_Correct_Predictions_SBP++;
end
// End Static Branch Predictor.



// Begin Dynamic Branch Predictor.
// This implementation predicts branches based on a branch history table.
logic [`TABLE_ADR_WIDTH-1:0] Table_Index;
assign Table_Index = pc[`TABLE_ADR_WIDTH+1:2];
logic [31:0] Total_Correct_Predictions_DBP = 0;
logic [`TABLE_WIDTH-1:0] Branch_History_Table [0:`TABLE_SIZE-1];

// Initialize all Branch History Table entries to zeros.
initial
begin
    for( int i=0; i<`TABLE_SIZE; i++)
    begin
        Branch_History_Table[i] = 0;
    end
end

// Make prediction.
logic Predict_Taken;
always_comb
begin
    if( Is_Branch_Instruction && (Branch_History_Table[Table_Index] > 1) )
        Predict_Taken = 1;
    else
        Predict_Taken = 0;
end

// Update prediction counter.
always_ff @ (posedge clk)
begin
    if( (Branch_Taken == Predict_Taken) && Is_Branch_Instruction )
        Total_Correct_Predictions_DBP++;
end

// Update Branch History Table.
always_ff @ (posedge clk)
begin
    if( Branch_Taken && (Branch_History_Table[Table_Index] < 3) )
        Branch_History_Table[Table_Index]++;
    else if( Branch_Not_Taken && (Branch_History_Table[Table_Index] > 0) )
        Branch_History_Table[Table_Index]--;
end
// End Dynamic Branch Predictor.



endmodule
