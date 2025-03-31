vim9script

const PI: float = acos(-1)

class Vec
	public var x: float
	public var y: float
	public var z: float
	public var w: float

	def new(this.x = v:none, this.y = v:none, this.z = v:none, this.w = v:none)
	enddef

	def newCopy(v: Vec)
		this.x = v.x
		this.y = v.y
		this.z = v.z
		this.w = v.w
	enddef

	def newAdd(u: Vec, v: Vec)
		this.x = u.x + v.x
		this.y = u.y + v.y
		this.z = u.z + v.z
		this.w = u.w + v.w
	enddef

	def newSub(u: Vec, v: Vec)
		this.x = u.x - v.x
		this.y = u.y - v.y
		this.z = u.z - v.z
		this.w = u.w - v.w
	enddef

	def newMul(v: Vec, s: float)
		this.x = v.x * s
		this.y = v.y * s
		this.z = v.z * s
		this.w = v.w * s
	enddef

	def newDiv(v: Vec)
		this.x = v.x / v.w
		this.y = v.y / v.w
		this.z = v.z / v.w
		this.w = v.w / v.w
	enddef

	def Add(v: Vec)
		this.x += v.x
		this.y += v.y
		this.z += v.z
		this.w += v.w
	enddef

	def Mul(s: float)
		this.x *= s
		this.y *= s
		this.z *= s
		this.w *= s
	enddef

	def Dot(v: Vec): float
		return this.x * v.x + this.y * v.y + this.z * v.z + this.w * v.w
	enddef

	def Length(): float
		return sqrt(this.Dot(this))
	enddef
endclass

class Mat
	var v0: Vec = Vec.new(1.0)
	var v1: Vec = Vec.new(0.0, 1.0)
	var v2: Vec = Vec.new(0.0, 0.0, 1.0)
	var v3: Vec = Vec.new(0.0, 0.0, 0.0, 1.0)

	def new(this.v0 = v:none, this.v1 = v:none, this.v2 = v:none, this.v3 = v:none)
	enddef

	def newPerspective(fovy: float, aspect: float, zNear: float, zFar: float)
		const tanHalfFovy: float = tan(fovy / 2.0)
		this.v0.x = 1.0 / (tanHalfFovy * aspect)
		this.v1.y = 1.0 / tanHalfFovy
		this.v2.z = (zNear + zFar) / (zNear - zFar)
		this.v2.w = -1.0
		this.v3.z = (2.0 * zNear * zFar) / (zNear - zFar)
		this.v3.w = 0.0
	enddef

	def newTranslate(v: Vec)
		this.v3.x = v.x
		this.v3.y = v.y
		this.v3.z = v.z
	enddef

	def newRoll(angle: float)
		const c: float = cos(angle)
		const s: float = sin(angle)
		this.v0.x = c
		this.v0.y = s
		this.v1.x = -s
		this.v1.y = c
	enddef

	def newPitch(angle: float)
		const c: float = cos(angle)
		const s: float = sin(angle)
		this.v1.y = c
		this.v1.z = s
		this.v2.y = -s
		this.v2.z = c
	enddef

	def newYaw(angle: float)
		const c: float = cos(angle)
		const s: float = sin(angle)
		this.v2.z = c
		this.v2.x = s
		this.v0.z = -s
		this.v0.x = c
	enddef

	def newScale(v: Vec)
		this.v0.x = v.x
		this.v1.y = v.y
		this.v2.z = v.z
	enddef

	def newMul(m1: Mat, m: Mat)
		this.v0 = m1.Vec(m.v0)
		this.v1 = m1.Vec(m.v1)
		this.v2 = m1.Vec(m.v2)
		this.v3 = m1.Vec(m.v3)
	enddef

	def Vec(v: Vec): Vec
		return Vec.newAdd(
			Vec.newAdd(Vec.newMul(this.v0, v.x), Vec.newMul(this.v1, v.y)),
			Vec.newAdd(Vec.newMul(this.v2, v.z), Vec.newMul(this.v3, v.w)),
		)
	enddef

	def Mul(m: Mat): Mat
		const v0: Vec = this.Vec(m.v0)
		const v1: Vec = this.Vec(m.v1)
		const v2: Vec = this.Vec(m.v2)
		const v3: Vec = this.Vec(m.v3)
		this.v0 = v0
		this.v1 = v1
		this.v2 = v2
		this.v3 = v3
		return this
	enddef

	def Translate(v: Vec): Mat
		this.v3 = this.Vec(v)
		return this
	enddef

	def Roll(angle: float): Mat
		const c: float = cos(angle)
		const s: float = sin(angle)
		const v0: Vec = Vec.newMul(this.v0, c)
		const v1: Vec = Vec.newMul(this.v1, s)
		const v2: Vec = Vec.newMul(this.v0, -s)
		const v3: Vec = Vec.newMul(this.v1, c)
		this.v0 = Vec.newAdd(v0, v1)
		this.v1 = Vec.newAdd(v2, v3)
		return this
	enddef

	def Pitch(angle: float): Mat
		const c: float = cos(angle)
		const s: float = sin(angle)
		const v0: Vec = Vec.newMul(this.v1, c)
		const v1: Vec = Vec.newMul(this.v2, s)
		const v2: Vec = Vec.newMul(this.v1, -s)
		const v3: Vec = Vec.newMul(this.v2, c)
		this.v1 = Vec.newAdd(v0, v1)
		this.v2 = Vec.newAdd(v2, v3)
		return this
	enddef

	def Yaw(angle: float): Mat
		const c: float = cos(angle)
		const s: float = sin(angle)
		const v0: Vec = Vec.newMul(this.v2, c)
		const v1: Vec = Vec.newMul(this.v0, s)
		const v2: Vec = Vec.newMul(this.v2, -s)
		const v3: Vec = Vec.newMul(this.v0, c)
		this.v2 = Vec.newAdd(v0, v1)
		this.v0 = Vec.newAdd(v2, v3)
		return this
	enddef

	def Scale(v: Vec): Mat
		this.v0.Mul(v.x)
		this.v1.Mul(v.y)
		this.v2.Mul(v.z)
		this.v3.Mul(v.w)
		return this
	enddef
endclass

class Vertex
	final position: Vec
	final color: Vec

	def new(this.position = v:none, this.color = v:none)
	enddef

	def newCopy(v: Vertex)
		this.position = Vec.newCopy(v.position)
		this.color = Vec.newCopy(v.color)
	enddef

	def newSub(u: Vertex, v: Vertex)
		this.position = Vec.newSub(u.position, v.position)
		this.color = Vec.newSub(u.color, v.color)
	enddef

	def Add(v: Vertex)
		this.position.Add(v.position)
		this.color.Add(v.color)
	enddef

	def Mul(s: float)
		this.position.Mul(s)
		this.color.Mul(s)
	enddef
endclass

class Element
	const x: number
	const y: number
	const z: number
	const fragment: string

	def new(this.x = v:none, this.y = v:none, this.z = v:none, this.fragment = v:none)
	enddef
endclass

class Fragment
	public var fragment: string = ' '
	public var depth: float = 1.0
	public var color: Vec = Vec.new()

	def new(this.fragment = v:none, this.depth = v:none, this.color = v:none)
	enddef

	def Hex(color: float): number
		const hex: number = float2nr(color * 255.0)
		if hex < 0
			return 0
		elseif hex > 255
			return 255
		else
			return hex
		endif
	enddef

	def Color(): string
		return printf('#%02x%02x%02x', this.Hex(this.color.x), this.Hex(this.color.y), this.Hex(this.color.z))
	enddef

	def TTYColor(): number
		if this.color.x < 0.25 && this.color.y < 0.25 && this.color.z < 0.25
			return 0
		elseif this.color.x < 0.25 && this.color.y < 0.25 && this.color.z >= 0.25 && this.color.z < 0.5
			return 1
		elseif this.color.x < 0.25 && this.color.y >= 0.25 && this.color.y < 0.5 && this.color.z < 0.25
			return 2
		elseif this.color.x < 0.25 && this.color.y >= 0.25 && this.color.y < 0.5 && this.color.z >= 0.25 && this.color.z < 0.5
			return 3
		elseif this.color.x >= 0.25 && this.color.x < 0.5 && this.color.y < 0.25 && this.color.z < 0.25
			return 4
		elseif this.color.x >= 0.25 && this.color.x < 0.5 && this.color.y < 0.25 && this.color.z >= 0.25 && this.color.z < 0.5
			return 5
		elseif this.color.x >= 0.25 && this.color.x < 0.5 && this.color.y >= 0.25 && this.color.y < 0.5 && this.color.z < 0.25
			return 6
		elseif this.color.x >= 0.25 && this.color.x < 0.5 && this.color.y >= 0.25 && this.color.y < 0.5 && this.color.z >= 0.25 && this.color.z < 0.5
			return 8
		elseif this.color.x < 0.5 && this.color.y < 0.5 && this.color.z >= 0.5
			return 9
		elseif this.color.x < 0.5 && this.color.y >= 0.5 && this.color.z < 0.5
			return 10
		elseif this.color.x < 0.5 && this.color.y >= 0.5 && this.color.z >= 0.5
			return 11
		elseif this.color.x >= 0.5 && this.color.y < 0.5 && this.color.z < 0.5
			return 12
		elseif this.color.x >= 0.5 && this.color.y < 0.5 && this.color.z >= 0.5
			return 13
		elseif this.color.x >= 0.5 && this.color.y >= 0.5 && this.color.z < 0.5
			return 14
		elseif this.color.x >= 0.75 && this.color.y >= 0.75 && this.color.z >= 0.75
			return 7
		else
			return 15
		endif
	enddef

	def Highlight()
		exec $'hi 3DVimFragment term=NONE ctermfg={this.TTYColor()} ctermbg=NONE cterm=NONE gui=NONE guifg={this.Color()} guibg=NONE'
		echohl 3DVimFragment
	enddef
endclass

interface Model
	var vertices: list<Vertex>
	var elements: list<Element>
endinterface

class Cube implements Model
	const vertices: list<Vertex> = [
		Vertex.new(
			Vec.new(-1.0, -1.0, 1.0, 1.0),
			Vec.new(0.0, 0.0, 0.0),
		),
		Vertex.new(
			Vec.new(1.0, -1.0, 1.0, 1.0),
			Vec.new(0.0, 0.0, 1.0),
		),
		Vertex.new(
			Vec.new(1.0, -1.0, -1.0, 1.0),
			Vec.new(0.0, 1.0, 0.0),
		),
		Vertex.new(
			Vec.new(-1.0, -1.0, -1.0, 1.0),
			Vec.new(0.0, 1.0, 1.0),
		),
		Vertex.new(
			Vec.new(-1.0, 1.0, 1.0, 1.0),
			Vec.new(1.0, 0.0, 0.0),
		),
		Vertex.new(
			Vec.new(1.0, 1.0, 1.0, 1.0),
			Vec.new(1.0, 0.0, 1.0),
		),
		Vertex.new(
			Vec.new(1.0, 1.0, -1.0, 1.0),
			Vec.new(1.0, 1.0, 0.0),
		),
		Vertex.new(
			Vec.new(-1.0, 1.0, -1.0, 1.0),
			Vec.new(1.0, 1.0, 1.0),
		),
	]

	const elements: list<Element> = [
		Element.new(0, 3, 2, 'a'),
		Element.new(2, 1, 0, 'b'),
		Element.new(0, 1, 5, 'c'),
		Element.new(5, 4, 0, 'd'),
		Element.new(1, 2, 6, 'e'),
		Element.new(6, 5, 1, 'f'),
		Element.new(2, 3, 7, 'G'),
		Element.new(7, 6, 2, 'H'),
		Element.new(3, 0, 4, 'I'),
		Element.new(4, 7, 3, 'J'),
		Element.new(4, 5, 6, 'K'),
		Element.new(6, 7, 4, 'L'),
	]

	def new(this.vertices = v:none, this.elements = v:none)
	enddef
endclass

class Camera
	var camera: Mat = Mat.new()

	def new(this.camera = v:none)
	enddef

	def newCamera(Translate: float, Rotate: Vec, fovy: float, aspect: float)
		const Projection: Mat = Mat.newPerspective(fovy, aspect, 0.1, 100.0)
		const ModelView: Mat = Mat.newTranslate(Vec.new(0.0, 0.0, -Translate)).Pitch(-Rotate.y * PI).Yaw(Rotate.x * PI).Scale(Vec.new(0.5, 0.5, 0.5, 1.0))
		this.camera = Projection.Mul(ModelView)
	enddef

	def Mul(v: Vertex): Vertex
		return Vertex.new(Vec.newDiv(this.camera.Vec(v.position)), v.color)
	enddef
endclass

class Viewport
	const width: number = 38
	const height: number = 9
	const delta: float
	const fovy: float = PI * 0.1
	final aspect: float = 0.4
	var camera: Camera
	final buffer: list<list<Fragment>>

	def new(this.width = v:none, this.height = v:none, this.fovy = v:none, this.aspect = v:none)
		this.delta = 2.0 / (this.width > this.height ? this.width : this.height)

		for row: number in range(this.height)
			this.buffer->add([])
			for column: number in range(this.width)
				this.buffer[row]->add(Fragment.new())
			endfor
		endfor

		this.aspect *= this.width / this.height
		const angle: float = (localtime() % 40) / 20.0
		this.camera = Camera.newCamera(6.0, Vec.new(2.0 * angle, angle), this.fovy, this.aspect)
	enddef

	def Clear()
		this.buffer->map((_, row: list<Fragment>) => row->map((_, _) => Fragment.new()))

		const angle: float = (localtime() % 40) / 20.0
		this.camera = Camera.newCamera(6.0, Vec.new(2.0 * angle, angle), this.fovy, this.aspect)
	enddef

	def Render(model: Model)
		const v: list<Vertex> = copy(model.vertices)->map((_, v: Vertex) => this.camera.Mul(v))
		for element: Element in model.elements
			this.Triangle(v[element.x], v[element.y], v[element.z], element.fragment)
		endfor
	enddef

	def Triangle(A: Vertex, B: Vertex, C: Vertex, fragment: string)
		final u: Vertex = Vertex.newSub(B, A)
		final v: Vertex = Vertex.newSub(C, A)
		const IIuII: float = u.position.Length()
		const IIvII: float = v.position.Length()

		if IIuII > 0.0 && IIvII > 0.0
			var dy1: float = this.delta / IIuII
			if dy1 > 1.0
				dy1 = 1.0
			endif

			var dy2: float = this.delta / IIvII
			if dy2 > 1.0
				dy2 = 1.0
			endif

			u.Mul(dy1)
			v.Mul(dy2)

			final U: Vertex = Vertex.newCopy(A)
			var y1: float
			while y1 < 1.0
				final V: Vertex = Vertex.newCopy(U)
				var y2: float
				while y1 + y2 < 1.0
					const depth: float = V.position.z
					if abs(depth) <= 1.0
						const row: number = float2nr(this.height * (1.0 - V.position.y) / 2.0)
						const column: number = float2nr(this.width * (V.position.x + 1.0) / 2.0)
						if (
							row >= 0 &&
							row < this.height &&
							column >= 0 &&
							column < this.width &&
							this.buffer[row][column].depth >= depth
						)
							this.buffer[row][column].fragment = fragment
							this.buffer[row][column].depth = depth
							this.buffer[row][column].color = Vec.newCopy(V.color)
						endif
					endif
					V.Add(v)
					y2 += dy2
				endwhile
				U.Add(u)
				y1 += dy1
			endwhile
		endif
	enddef

	def Echo()
		for row: list<Fragment> in this.buffer
			for column: Fragment in row
				column.Highlight()
				echon column.fragment
				echohl None
			endfor
			echon "\n"
		endfor
	enddef
endclass

final viewport: Viewport = Viewport.new()
final geometry: list<Model> = [Cube.new()]

if str2nr(&t_Co) > 16
	set termguicolors
endif

def Main()
	viewport.Clear()
	for model: Model in geometry
		viewport.Render(model)
	endfor
	viewport.Echo()
enddef

Main()
