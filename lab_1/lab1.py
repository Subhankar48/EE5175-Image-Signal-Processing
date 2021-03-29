# importing libraries
import numpy as np
import imageio
import matplotlib.pyplot as plt
import sys

# reading images
cells = imageio.imread("cells_scale.png")
lena = imageio.imread("lena_translate.png")
pisa = imageio.imread("pisa_rotate.png")


def floor(value):
    # example of how the int function works
    # int(1.3) = 1, int(3.8) = 3
    # int(-0.1) = 0, int(-4.8) = -4
    if value >= 0:
        return int(value)
    else:
        return int(value)-1


def bilinear_interpolate(zero_padded_source_image, x, y):
    # shape of the zero padded image
    dx, dy = np.shape(zero_padded_source_image)
    # get the shape of the original image
    dx, dy = dx-2, dy-2
    # +1 as we are taking coordinates with respect to a zero padded image
    x, y = x+1, y+1

    # x', y', a, b as defined in the lecture
    x_prime, y_prime = floor(x), floor(y)
    a = x-x_prime
    b = y-y_prime

    if x_prime >= 0 and x_prime <= dx and y_prime >= 0 and y_prime <= dy:
        # intensity value using bilinear interpolation
        intensity_val = (1-a)*(1-b)*zero_padded_source_image[x_prime, y_prime] \
            + (1-a)*b*zero_padded_source_image[x_prime, y_prime+1] \
            + a*(1-b)*zero_padded_source_image[x_prime+1, y_prime] \
            + a*b*zero_padded_source_image[x_prime+1, y_prime+1]
    else:
        # If the (xs, ys) does not exist in the source image, assign 0
        # for the corresponding (xt, yt) in the target image
        intensity_val = 0

    return intensity_val


def transform(source_image, transform_type, params):
    # zero padding the image for bilinear interpolation
    x, y = np.shape(source_image)
    image = np.zeros((x+2, y+2))
    image[1:-1, 1:-1] = source_image
    # center of the given image
    center_x, center_y = x/2, y/2

    target_image = np.zeros((x, y))

    if transform_type == "translate":
        tx, ty = params
        for xt in range(x):
            for yt in range(y):
                xs = xt-tx
                ys = yt-ty
                val = bilinear_interpolate(image, xs, ys)
                target_image[xt, yt] = val

    elif transform_type == "rotate":
        theta = params
        # convert to radians as NumPy uses radians
        theta *= np.pi/180
        for xt in range(x):
            for yt in range(y):
                # rotate about the center
                # To rotate around a point (x0, y0), we first translate to that point
                x_c, y_c = xt-center_x, yt - center_y
                # Then we apply rotation as we would apply rotation around the origin
                # And then translate back
                xs = np.cos(theta)*x_c - np.sin(theta)*y_c + center_x
                ys = np.cos(theta)*y_c + np.sin(theta)*x_c + center_y
                val = bilinear_interpolate(image, xs, ys)
                target_image[xt, yt] = val

    elif transform_type == "scale":
        scale = params
        # If scale factor is positive, then do the transform
        if scale > 0:
            for xt in range(x):
                for yt in range(y):
                    # scale about the center as it looks more aesthetically pleasing
                    # To scale around a point (x0, y0), we first translate to that point
                    # Then we apply rotation as we would apply rotation around the origin
                    # And then translate back
                    xs = (xt-center_x)/scale+center_x
                    ys = (yt-center_y)/scale+center_y
                    val = bilinear_interpolate(image, xs, ys)
                    target_image[xt, yt] = val

        # Else set the target image to zero (already initialized to zero on line 58)
        # This also prevents division by zero errors
    return target_image


def plotter(image, transformed_image, title_1, title_2):
    ax1 = plt.subplot(1, 2, 1, frameon=False)
    ax2 = plt.subplot(1, 2, 2, frameon=False)
    ax1.set_xticks([])
    ax1.set_yticks([])
    ax2.set_xticks([])
    ax2.set_yticks([])
    ax1.imshow(image, 'gray')
    ax2.imshow(transformed_image, 'gray')
    ax1.title.set_text(title_1)
    ax2.title.set_text(title_2)
    plt.axis('off')
    plt.show()
    
    # plt.imshow(image, "gray")
    # plt.title(title_1)
    # plt.axis('off')
    # plt.show()

    # plt.imshow(transformed_image, "gray")
    # plt.title(title_2)
    # plt.axis('off')
    # plt.show()
        

# main function
if __name__ == "__main__":
    print("Enter 1 to see results for manual values")
    print("Enter 0 to see results for default values")
    choose = int(input())
    if choose == 1:
        print("Select 1 for translation, 2 for rotation and 3 for scaling")
        try:
            choice = int(input())
            if choice == 1:
                print("Choose tx and ty")
                tx = float(input("Enter tx:\n"))
                ty = float(input("Enter ty:\n"))
                new_lena = transform(
                    lena, transform_type="translate", params=(tx, ty))
                plotter(lena, new_lena, "Original image",
                        f"Image translated by tx={tx} and ty={ty}")

            elif choice == 2:
                print("Choose the angle to rotate by in degrees")
                print("NOTE: Choosing theta = -3.75 degrees gives very good results")
                theta = float(input())
                new_pisa = transform(
                    pisa, transform_type="rotate", params=theta)
                plotter(pisa, new_pisa, "Original image",
                        f"Image rotated by {theta} degrees")

            elif choice == 3:
                print("Choose the scale factor")
                scale_factor = float(input())
                # Ensure scale factor is non negative
                assert scale_factor >= 0
                new_cells = transform(
                    cells, transform_type="scale", params=scale_factor)
                plotter(cells, new_cells, "Original image",
                        f"Image scaled by a factor of {scale_factor}")
        except:
            print("Wrong input type. Try again.")
            sys.exit(0)

    else:
        new_lena = transform(
            lena, transform_type="translate", params=(3.75, 4.3))
        plotter(lena, new_lena, "Original image",
                "Image translated by tx=3.75 and ty=4.3")
        new_pisa = transform(pisa, transform_type="rotate", params=-3.75)
        plotter(pisa, new_pisa, "Original image",
                "Image rotated by -3.75 degrees")
        new_cells = transform(cells, transform_type="scale", params=0.8)
        plotter(cells, new_cells, "Original image",
                f"Image scaled by a factor of 0.8")
        new_cells = transform(cells, transform_type="scale", params=1.3)
        plotter(cells, new_cells, "Original image",
                f"Image scaled by a factor of 1.3")
