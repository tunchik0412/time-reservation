import { Column, Entity, ManyToMany, PrimaryGeneratedColumn } from "typeorm";
import { Record } from "../../records/entities/record.entity";
import { Exclude } from "class-transformer";

@Entity()
export class User {
  /**
   * this decorator will help to auto generate id for the table.
   */
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 30 })
  name: string;

  @Column({ type: 'varchar', length: 40 })
  email: string;

  @Column({ type: 'varchar', select: false })
  password: string;

  @ManyToMany(() => Record, record => record.participants)
  records: Record[];
}
