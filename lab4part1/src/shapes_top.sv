
virtual class shape;
	protected real width;
	protected real height;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction
	
	function real get_width();
		return width;
	endfunction
	
	function real get_height();
		return height;
	endfunction
	
	pure virtual function real get_area();
	
	pure virtual function void print();
	
endclass : shape

class rectangle extends shape;
	
	function new(real w, real h);
		super.new(w,h);
	endfunction
	
	function real get_area();
		return get_width()*get_height();
	endfunction
	
	function void print();
		$display("Rectangle w=%g h=%g, area=%g", get_width(), get_height(), get_area());
	endfunction

endclass : rectangle

class square extends rectangle;
	
	function new(real w);
		super.new(w,w);
	endfunction
	
	function void print();
		$display("Square w=%g, area=%g", get_width(), get_area());
	endfunction
	
endclass

class triangle extends shape;
	
	function new(real w, real h);
		super.new(w,h);
	endfunction
	
	function real get_area();
		return get_width()*get_height()/2;
	endfunction
	
	function void print();
		$display("Triangle w=%g h=%g, area=%g", get_width(), get_height(), get_area());
	endfunction
	
endclass

class shape_reporter #(type T=shape);
	
	protected static T shape_storage[$];
	
	static function void store_shape(T s);
		shape_storage.push_back(s);
	endfunction
	
	static function void report_shapes();
		real area_sum = 0;
		foreach(shape_storage[i]) begin
			shape_storage[i].print();
			area_sum += shape_storage[i].get_area();
		end
		$display("Total area: %g\n", area_sum);
	endfunction
			
endclass	

class shape_factory;
	
	static function shape make_shape(string shape_type, real w, real h);
		
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		case(shape_type)
			"rectangle": begin
				rectangle_h = new(w,h);
				shape_reporter#(rectangle)::store_shape(rectangle_h);
				return rectangle_h;
			end
			"square": begin
				square_h = new(w);
				shape_reporter#(square)::store_shape(square_h);
				return square_h;
			end
			"triangle": begin
				triangle_h = new(w,h);
				shape_reporter#(triangle)::store_shape(triangle_h);
				return triangle_h;
			end
			default: 
				$fatal (1, {"No such shape: ", shape_type});
		endcase
	endfunction
	
endclass

module top;
	
	initial begin
		
//		rectangle rectangle_h;
//		square square_h;
//		triangle triangle_h;
		
		int file;
		string shape_type;
		real width;
		real height;
		
		file = $fopen("./lab04part1_shapes.txt", "r");
		
		while($fscanf(file, "%s %g %g", shape_type, width, height) == 3) begin
			void'(shape_factory::make_shape(shape_type, width, height));
//			case(shape_type)
//				"rectangle":
//					$cast(rectangle_h, );
//				"square":
//					$cast(square_h, shape_factory::make_shape(shape_type, width, height));
//				"triangle":
//					$cast(triangle_h, shape_factory::make_shape(shape_type, width, height));
//				default:
//					$fatal (1, {"No such shape: ", shape_type});
//			endcase
		end

		shape_reporter#(rectangle)::report_shapes();
		shape_reporter#(square)::report_shapes();
		shape_reporter#(triangle)::report_shapes();
		
		$fclose(file);
		
	end
	
endmodule
