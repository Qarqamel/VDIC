
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

class shape_factory;
	
	static function shape make_shape(string shape_type, real w, real h);
		
		rectangle rectangle_h;
		square square_h;
		triangle triangle_h;
		
		case(shape_type)
			"rectangle": begin
				rectangle_h = new(w,h);
				return rectangle_h;
			end
			"square": begin
				square_h = new(w);
				return square_h;
			end
			"triangle": begin
				triangle_h = new(w,h);
				return triangle_h;
			end
			default: 
				$fatal (1, {"No such shape: ", shape_type});
		endcase
	endfunction
	
endclass

class animal_cage #(type T=animal);

   static T cage[$];

   static function void cage_animal(T l);
      cage.push_back(l);
   endfunction : cage_animal

   static function void list_animals();
      $display("Animals in cage:"); 
      foreach (cage[i])
        $display(cage[i].get_name());
   endfunction : list_animals

endclass : animal_cage

class shape_reporter #(type T=shape);
	
	protected static T rectangle_storage[$];
	protected static T square_storage[$];
	protected static T triangle_storage[$];
	
	static function void store_shape(string shape_type, T s);
		case (shape_type)
			"rectangle":
				rectangle_storage.push_back(s);
			"square":
				square_storage.push_back(s);
			"triangle":
				triangle_storage.push_back(s);
			default:
				$fatal (1, {"No such shape: ", shape_type});
		endcase
	endfunction
	
	static function void report_shapes();
		real area_sum = 0;
		foreach (rectangle_storage[i]) begin
			rectangle_storage[i].print();
			area_sum += rectangle_storage[i].get_area();
		end
		$display("Total area: %g\n", area_sum);
		area_sum = 0;
		foreach (rectangle_storage[i]) begin
			rectangle_storage[i].print();
			area_sum += rectangle_storage[i].get_area();
		end
		$display("Total area: %g\n", area_sum);
		area_sum = 0;
		foreach (rectangle_storage[i]) begin
			rectangle_storage[i].print();
			area_sum += rectangle_storage[i].get_area();
		end
		$display("Total area: %g\n", area_sum);
	endfunction
	
endclass	


